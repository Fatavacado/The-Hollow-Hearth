"""Forest terrain tiles (dual-grid transitions), decor tiles and outdoor props.

Terrain atlas `tiles/forest_terrain.png` (32x32 tiles, 16 columns):
  row 0: grass<->path    transitions, column = corner mask (TL=1, TR=2, BL=4, BR=8; bit = path)
  row 1: grass<->water   transitions (bit = water)
  row 2: grass<->canopy  transitions (bit = canopy)
  row 3: pure variants   0-3 grass, 4-7 path, 8-11 water, 12-15 canopy
Decor atlas `tiles/forest_decor.png` (32x32, transparent): flowers, tufts, pebbles, leaves.
All tiles of one terrain pair share one periodic noise field, so edges stay seamless.
"""
from __future__ import annotations

import math
import random

from PIL import Image

from pixelkit import C, ROOT, TileNoise, fractal, new, outline, preview, put, rect, save, shade_by_light

T = 32


def wput(img, x, y, color):
    img.putpixel((x % T, y % T), color)


# ------------------------------------------------------------------ base textures
def grass_base(seed=11) -> Image.Image:
    img = new(T, T)
    n1, n2 = TileNoise(seed, T, 8), TileNoise(seed + 1, T, 4)
    for y in range(T):
        for x in range(T):
            v = fractal([n1, n2], x, y)
            img.putpixel((x, y), C("g2" if v < 0.3 else "g4" if v > 0.7 else "g3"))
    rng = random.Random(seed)
    for _ in range(34):
        x, y = rng.randrange(T), rng.randrange(T)
        wput(img, x, y, C("g5"))
        wput(img, x, y + 1, C("g4"))
        wput(img, x + 1, y + 1, C("g2"))
    return img


def grass_variant(base, i) -> Image.Image:
    img = base.copy()
    rng = random.Random(100 + i)
    for _ in range(3 + i * 2):  # details stay away from edges so variants tile with each other
        x, y = rng.randrange(4, T - 5), rng.randrange(4, T - 5)
        for bx in range(3):
            put(img, x + bx, y + (1 if bx == 1 else 2), C("g5"))
            put(img, x + bx, y + 3, C("g2"))
    return img


def path_base(seed=21) -> Image.Image:
    img = new(T, T)
    n1, n2 = TileNoise(seed, T, 8), TileNoise(seed + 1, T, 4)
    for y in range(T):
        for x in range(T):
            v = fractal([n1, n2], x, y)
            img.putpixel((x, y), C("d1" if v < 0.3 else "d3" if v > 0.7 else "d2"))
    return img


def path_variant(base, i) -> Image.Image:
    img = base.copy()
    rng = random.Random(200 + i)
    for _ in range(4 + i):
        x, y = rng.randrange(4, T - 5), rng.randrange(4, T - 5)
        put(img, x, y, C("d0"))
        put(img, x + 1, y, C("d1"))
        put(img, x, y - 1, C("d4"))
    return img


def water_base(seed=31) -> Image.Image:
    img = new(T, T)
    n1, n2 = TileNoise(seed, T, 4), TileNoise(seed + 1, T, 8)
    for y in range(T):
        for x in range(T):
            v = fractal([n1, n2], x, y)
            img.putpixel((x, y), C("b1" if v < 0.24 else "b3" if v > 0.8 else "b2"))
    return img


def water_variant(base, i) -> Image.Image:
    img = base.copy()
    rng = random.Random(300 + i)
    for _ in range(3):
        x, y = rng.randrange(4, T - 8), rng.randrange(4, T - 5)
        rect(img, x, y, x + 3, y, C("b4"))
        put(img, x + 1, y, C("b5"))
    return img


def canopy_base(seed=41) -> Image.Image:
    img = new(T, T)
    for y in range(T):
        for x in range(T):
            img.putpixel((x, y), C("g0"))
    rng = random.Random(seed)
    for _ in range(26):
        cx, cy, r = rng.randrange(T), rng.randrange(T), rng.choice([4, 5, 5, 6])
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                d = math.hypot(dx, dy)
                if d > r:
                    continue
                if dx + dy > r * 0.5 and d > r - 2:
                    c = "g0"
                elif dx + dy < -r * 0.5:
                    c = "g3"
                else:
                    c = "g2" if d < r - 1 else "g1"
                wput(img, cx + dx, cy + dy, C(c))
        wput(img, cx - r // 2, cy - r // 2, C("g4"))
    return img


# ------------------------------------------------------------------ transitions
def transition(lower: Image.Image, upper: Image.Image, mask: int, kind: str, seed: int) -> Image.Image:
    tl, tr, bl, br = [(mask >> i) & 1 for i in range(4)]
    nz = [TileNoise(seed, T, 16), TileNoise(seed + 1, T, 8)]
    amp = {"path": 0.5, "water": 0.4, "canopy": 0.7}[kind]

    def field(x, y):
        u, v = (x + 0.5) / T, (y + 0.5) / T
        f = (tl * (1 - u) + tr * u) * (1 - v) + (bl * (1 - u) + br * u) * v
        return f + (fractal(nz, x % T, y % T) - 0.5) * amp

    def up(x, y):
        return field(x, y) > 0.5

    img = new(T, T)
    for y in range(T):
        for x in range(T):
            if up(x, y):
                c = upper.getpixel((x, y))
                near_lower = not (up(x - 1, y) and up(x + 1, y) and up(x, y - 1) and up(x, y + 1))
                if near_lower:
                    if kind == "path":
                        c = C("d1")
                    elif kind == "water":
                        c = C("b1") if not up(x, y - 1) else C("b4")
                    else:
                        c = C("outline") if not up(x, y + 1) else C("g0")
                elif kind == "water" and not (up(x, y - 2) and up(x - 2, y) and up(x + 2, y)):
                    c = C("b3")
            else:
                c = lower.getpixel((x, y))
                if kind == "canopy":
                    if up(x, y - 1) or up(x, y - 2):
                        c = C("g1")
                    elif up(x, y - 3) or up(x, y - 4):
                        c = C("g2")
                elif kind == "water" and (up(x, y + 1) or up(x - 1, y) or up(x + 1, y) or up(x, y - 1)):
                    c = C("d1")
                elif kind == "path" and (up(x, y + 1) or up(x - 1, y) or up(x + 1, y)):
                    c = C("g5") if (x + y) % 3 == 0 else c
            img.putpixel((x, y), c)
    return img


# ------------------------------------------------------------------ decor
def decor_tiles() -> list[Image.Image]:
    tiles = []
    flowers = [("c4", "f4"), ("f4", "f2"), ("m3", "m4"), ("r3", "f4")]
    for i, (petal, centre) in enumerate(flowers):
        img = new(T, T)
        rng = random.Random(500 + i)
        for _ in range(4):
            x, y = rng.randrange(6, 26), rng.randrange(6, 26)
            put(img, x, y + 2, C("g2"))
            put(img, x, y + 3, C("g2"))
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                put(img, x + dx, y + dy, C(petal))
            put(img, x, y, C(centre))
        tiles.append(img)
    for i in range(2):  # tall grass tufts
        img = new(T, T)
        rng = random.Random(600 + i)
        for _ in range(2):
            x, y = rng.randrange(8, 22), rng.randrange(10, 24)
            for b, h in enumerate((4, 6, 5, 3)):
                bx = x + b * 2
                for k in range(h):
                    put(img, bx, y + 6 - k, C("g5" if k == h - 1 else "g4" if k > 1 else "g3"))
                put(img, bx, y + 7, C("g1"))
        tiles.append(img)
    img = new(T, T)  # pebbles
    rng = random.Random(700)
    for _ in range(4):
        x, y = rng.randrange(6, 26), rng.randrange(6, 26)
        rect(img, x, y, x + 1, y, C("s3"))
        put(img, x, y - 1, C("s4"))
        rect(img, x, y + 1, x + 1, y + 1, C("g1"))
    tiles.append(img)
    img = new(T, T)  # fallen leaves
    rng = random.Random(800)
    for _ in range(5):
        x, y = rng.randrange(5, 27), rng.randrange(5, 27)
        c = rng.choice(["f2", "f3", "w4"])
        put(img, x, y, C(c))
        put(img, x + 1, y, C(c))
        put(img, x + 1, y + 1, C("w3"))
    tiles.append(img)
    return tiles


# ------------------------------------------------------------------ props
def soft_shadow(img, cx, cy, rx, ry, alpha=70):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1:
                put(img, x, y, (24, 20, 30, alpha))


def blob(w, h, circles) -> Image.Image:
    img = new(w, h)
    for cx, cy, r in circles:
        for y in range(h):
            for x in range(w):
                if math.hypot(x + 0.5 - cx, y + 0.5 - cy) <= r:
                    img.putpixel((x, y), (255, 255, 255, 255))
    return img


def speckle(img, seed, light, dark, density=0.07):
    rng = random.Random(seed)
    for y in range(img.height):
        for x in range(img.width):
            if img.getpixel((x, y))[3] and rng.random() < density:
                img.putpixel((x, y), C(light if rng.random() < 0.5 else dark))


def oak_tree(seed: int) -> Image.Image:
    rng = random.Random(seed)
    w, h = 64, 84
    img = new(w, h)
    soft_shadow(img, 32, 77, 20, 5)
    # trunk + roots
    trunk = new(w, h)
    rect(trunk, 27, 50, 36, 76, C("w2"))
    rect(trunk, 24, 72, 39, 76, C("w2"))
    rect(trunk, 27, 50, 29, 76, C("w3"))
    rect(trunk, 34, 50, 36, 76, C("w1"))
    put(trunk, 31, 62, C("w1"))
    put(trunk, 31, 63, C("w1"))
    img.alpha_composite(outline(trunk))
    jitter = [rng.randint(-2, 2) for _ in range(6)]
    canopy = blob(w, h, [(32, 30, 22 + jitter[0] // 2), (14 + jitter[1], 40, 13), (50 + jitter[2], 40, 13),
                         (32, 13 + jitter[3], 14), (20, 22, 12), (44, 22, 12), (32, 46, 14)])
    shade_by_light(canopy, ["g0", "g1", "g2", "g3", "g4", "g5"])
    speckle(canopy, seed, "g4", "g1", 0.06)
    img.alpha_composite(outline(canopy, C("outline")))
    return img


def pine_tree(seed: int) -> Image.Image:
    w, h = 48, 92
    img = new(w, h)
    soft_shadow(img, 24, 86, 14, 4)
    trunk = new(w, h)
    rect(trunk, 21, 72, 26, 86, C("w2"))
    rect(trunk, 21, 72, 22, 86, C("w3"))
    img.alpha_composite(outline(trunk))
    tiers = new(w, h)
    for top, bottom, half in ((4, 34, 12), (18, 54, 17), (34, 76, 22)):
        for y in range(top, bottom + 1):
            t = (y - top) / (bottom - top)
            hw = int(2 + (half - 2) * t)
            for x in range(24 - hw, 24 + hw):
                tiers.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(tiers, ["g0", "g1", "g1", "g2", "g3", "g4"])
    speckle(tiers, seed, "g3", "g0", 0.05)
    img.alpha_composite(outline(tiers))
    return img


def bush() -> Image.Image:
    img = new(32, 30)
    soft_shadow(img, 16, 26, 13, 3)
    b = blob(32, 30, [(16, 15, 10), (8, 19, 7), (24, 19, 7), (16, 21, 8)])
    shade_by_light(b, ["g1", "g2", "g3", "g4", "g5"])
    speckle(b, 9, "g5", "g1", 0.05)
    img.alpha_composite(outline(b))
    return img


def rock() -> Image.Image:
    img = new(26, 22)
    soft_shadow(img, 13, 19, 11, 3)
    r = blob(26, 22, [(12, 12, 8), (17, 14, 6), (8, 15, 5)])
    shade_by_light(r, ["s1", "s2", "s3", "s4", "s5"])
    speckle(r, 3, "s4", "s2", 0.06)
    img.alpha_composite(outline(r, C("s0")))
    return img


def stump() -> Image.Image:
    img = new(30, 24)
    soft_shadow(img, 15, 20, 13, 3)
    s = new(30, 24)
    rect(s, 6, 9, 23, 19, C("w2"))
    rect(s, 6, 9, 9, 19, C("w3"))
    rect(s, 20, 9, 23, 19, C("w1"))
    for y in range(4, 13):
        for x in range(5, 25):
            if ((x + 0.5 - 15) / 10) ** 2 + ((y + 0.5 - 8.5) / 4.5) ** 2 <= 1:
                d = ((x + 0.5 - 15) / 10) ** 2 + ((y + 0.5 - 8.5) / 4.5) ** 2
                s.putpixel((x, y), C("w5" if d < 0.15 else "w4" if d < 0.45 else "w5" if d < 0.7 else "w4"))
    img.alpha_composite(outline(s))
    return img


# ------------------------------------------------------------------ tavern exterior
def tavern_exterior() -> Image.Image:
    w, h = 224, 200
    img = new(w, h)
    soft_shadow(img, 112, 190, 104, 7, 60)
    b = new(w, h)
    # chimney (behind roof)
    rect(b, 160, 6, 183, 70, C("s2"))
    for y in range(6, 70, 6):
        for x in range(160 + (6 if (y // 6) % 2 else 0), 184, 12):
            rect(b, x, y, x, y + 5, C("s1"))
        rect(b, 160, y, 183, y, C("s1"))
    rect(b, 160, 6, 162, 70, C("s3"))
    rect(b, 157, 2, 186, 6, C("s3"))
    # roof: shingle rows, trapezoid
    roof_top, roof_bottom = 30, 112
    for y in range(roof_top, roof_bottom + 1):
        t = (y - roof_top) / (roof_bottom - roof_top)
        x0, x1 = int(44 - 40 * t), int(180 + 40 * t)
        for x in range(x0, x1 + 1):
            row = (y - roof_top) // 7
            shingle_edge = (y - roof_top) % 7 == 6
            seam = (x + (row % 2) * 6) % 12 == 0
            c = "r0" if shingle_edge else ("r1" if seam else "r2")
            if x <= x0 + 1 or x >= x1 - 1:
                c = "r0"
            b.putpixel((x, y), C(c))
    rect(b, 44, roof_top - 2, 180, roof_top, C("r3"))      # ridge
    rect(b, 4, roof_bottom + 1, 219, roof_bottom + 3, C("r0"))  # eave shadow line
    # facade
    rect(b, 16, 112, 207, 175, C("c2"))
    for x in range(16, 208):
        for y in range(112, 176):
            if (x * 7 + y * 3) % 23 == 0:
                b.putpixel((x, y), C("c1"))
    rect(b, 16, 112, 207, 117, C("w1"))                      # top beam (in roof shadow)
    rect(b, 16, 140, 207, 143, C("w2"))                      # middle beam
    for px in (16, 76, 144, 204):
        rect(b, px, 112, px + 3, 175, C("w2"))
        rect(b, px, 112, px, 175, C("w3"))
    # foundation stones
    rect(b, 12, 168, 211, 187, C("s2"))
    for y in range(168, 188, 5):
        rect(b, 12, y, 211, y, C("s1"))
        for x in range(12 + (8 if (y // 5) % 2 else 0), 212, 16):
            rect(b, x, y, x, y + 4, C("s1"))
    rect(b, 12, 168, 211, 168, C("s3"))
    # windows (warm glow) with flower boxes
    for wx in (36, 164):
        rect(b, wx - 2, 120, wx + 25, 151, C("w1"))
        rect(b, wx, 122, wx + 23, 149, C("f4"))
        rect(b, wx, 122, wx + 23, 127, C("f5"))
        rect(b, wx + 11, 122, wx + 12, 149, C("w1"))
        rect(b, wx, 135, wx + 23, 136, C("w1"))
        rect(b, wx - 3, 152, wx + 26, 158, C("w3"))
        rect(b, wx - 3, 152, wx + 26, 152, C("w4"))
        for i, fc in enumerate(("r3", "f4", "m3", "r3", "c4", "f4", "m3")):
            fx = wx - 1 + i * 4
            rect(b, fx, 149, fx + 1, 151, C(fc))
            put(b, fx, 152, C("g3"))
    # door (arched)
    door_x0, door_x1, door_top = 98, 125, 124  # ~56px tall: taller than the ~46px characters
    for y in range(door_top - 6, 176):
        for x in range(door_x0 - 3, door_x1 + 4):
            dx = x - (door_x0 + door_x1) / 2
            if y < door_top + 8 and dx * dx + (y - (door_top + 8)) ** 2 * 1.6 > 17 ** 2:
                continue
            b.putpixel((x, y), C("w1"))
    for y in range(door_top - 3, 176):
        for x in range(door_x0, door_x1 + 1):
            dx = x - (door_x0 + door_x1) / 2
            if y < door_top + 8 and dx * dx + (y - (door_top + 8)) ** 2 * 1.6 > 14 ** 2:
                continue
            plank = (x - door_x0) % 7 == 0
            b.putpixel((x, y), C("w2" if plank else "w3"))
    for hy in (148, 164):
        rect(b, door_x0, hy, door_x0 + 8, hy + 1, C("s1"))
    rect(b, door_x1 - 4, 156, door_x1 - 3, 157, C("f4"))
    # step
    rect(b, 94, 176, 129, 187, C("s3"))
    rect(b, 94, 176, 129, 177, C("s4"))
    rect(b, 94, 187, 129, 187, C("s1"))
    # hanging sign with a hearth flame
    rect(b, 70, 124, 92, 125, C("w1"))
    rect(b, 72, 126, 72, 129, C("s1"))
    rect(b, 90, 126, 90, 129, C("s1"))
    rect(b, 68, 130, 94, 147, C("w4"))
    rect(b, 68, 130, 94, 130, C("w5"))
    rect(b, 68, 147, 94, 147, C("w2"))
    for (x, y, c) in ((81, 133, "f2"), (80, 134, "f2"), (81, 134, "f3"), (82, 134, "f2"),
                      (79, 135, "f2"), (80, 135, "f3"), (81, 135, "f4"), (82, 135, "f3"), (83, 135, "f2"),
                      (79, 136, "f2"), (80, 136, "f4"), (81, 136, "f5"), (82, 136, "f4"), (83, 136, "f2"),
                      (79, 137, "f1"), (80, 137, "f3"), (81, 137, "f4"), (82, 137, "f3"), (83, 137, "f1"),
                      (80, 138, "f1"), (81, 138, "f2"), (82, 138, "f1")):
        put(b, x, y, C(c))
    rect(b, 76, 140, 86, 142, C("s2"))
    # lanterns beside door
    for lx in (88, 132):
        rect(b, lx, 140, lx + 3, 146, C("f4"))
        rect(b, lx, 139, lx + 3, 139, C("s1"))
        put(b, lx + 1, 142, C("f5"))
    img.alpha_composite(outline(b))
    return img


def main() -> None:
    scratch = ROOT / ".godot" / "art_previews"
    scratch.mkdir(parents=True, exist_ok=True)

    grass, path, water, canopy = grass_base(), path_base(), water_base(), canopy_base()
    atlas = new(T * 16, T * 4)
    for kind_row, (kind, upper, seed) in enumerate((("path", path, 1001), ("water", water, 2002),
                                                     ("canopy", canopy, 3003))):
        for mask in range(16):
            atlas.alpha_composite(transition(grass, upper, mask, kind, seed), (mask * T, kind_row * T))
    variants = ([grass_variant(grass, i) for i in range(4)] + [path_variant(path, i) for i in range(4)]
                + [water_variant(water, i) for i in range(4)] + [canopy] * 4)
    for i, tile in enumerate(variants):
        atlas.alpha_composite(tile, (i * T, 3 * T))
    save(atlas, "tiles/forest_terrain.png")
    preview(atlas, scratch / "forest_terrain.png", scale=2)

    decor = decor_tiles()
    decor_atlas = new(T * len(decor), T)
    for i, tile in enumerate(decor):
        decor_atlas.alpha_composite(tile, (i * T, 0))
    save(decor_atlas, "tiles/forest_decor.png")

    props = {
        "props/oak_tree_a.png": oak_tree(1), "props/oak_tree_b.png": oak_tree(2),
        "props/pine_tree.png": pine_tree(3), "props/bush.png": bush(), "props/rock.png": rock(),
        "props/stump.png": stump(), "props/tavern_exterior.png": tavern_exterior(),
    }
    for rel, img in props.items():
        save(img, rel)
        preview(img, scratch / rel.replace("/", "_"), scale=3)
    print("wrote forest terrain, decor and", len(props), "props")


if __name__ == "__main__":
    main()
