"""Tavern interior tiles and furniture.

Tile atlas `tiles/tavern_tiles.png` (32x32, 8 columns):
  row 0: floor planks x4 | floor under back wall (shadowed) | doormat
  row 1: wall cap | upper wall | upper wall + post | lower wall (wainscot) | side wall L | side wall R | front wall
Furniture: one PNG per prop under props/ (origin = bottom centre unless noted in the scene).
"""
from __future__ import annotations

import random

from PIL import Image

from gen_font import G as GLYPHS
from pixelkit import C, ROOT, TileNoise, fractal, new, outline, preview, put, rect, save, shade_by_light
from gen_world import blob, soft_shadow

T = 32


def text(img, x, y, s, color):
    """Draws `s` with the Hearth Pixel glyphs at native size."""
    for ch in s:
        rows = GLYPHS.get(ch)
        if rows is None:
            x += 3
            continue
        for gy, row in enumerate(rows):
            for gx, bit in enumerate(row):
                if bit == "#":
                    put(img, x + gx, y + gy, color)
        x += len(rows[0]) + 1


def text_width(s):
    return sum(len(GLYPHS[c][0]) + 1 if c in GLYPHS else 3 for c in s) - 1


# ------------------------------------------------------------------ tiles
def floor(seed: int) -> Image.Image:
    img = new(T, T)
    nz = TileNoise(seed, T, 8)
    rng = random.Random(seed)
    offsets = [rng.randrange(0, 16) for _ in range(4)]
    for y in range(T):
        plank = y // 8
        for x in range(T):
            grain = fractal([nz], x * 0.5, y * 2)
            c = "w3" if grain < 0.33 else "w4" if grain < 0.82 else "w5"
            if y % 8 == 7:
                c = "w1"
            elif y % 8 == 0:
                c = "w4" if c != "w5" else "w5"
            if (x + offsets[plank]) % 16 == 0 and y % 8 != 7:
                c = "w2"
            img.putpixel((x, y), C(c))
    for _ in range(2):  # nail heads
        x, y = rng.randrange(2, 30), rng.randrange(0, 4) * 8 + 3
        put(img, x, y, C("w1"))
    return img


def wall_cap() -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, T - 1, C("w1"))
    rect(img, 0, 20, T - 1, 27, C("w2"))
    rect(img, 0, 20, T - 1, 20, C("w3"))
    rect(img, 0, 28, T - 1, 31, C("w0"))
    return img


def upper_wall(post: bool) -> Image.Image:
    img = new(T, T)
    nz = TileNoise(77, T, 4)
    for y in range(T):
        for x in range(T):
            v = fractal([nz], x, y)
            img.putpixel((x, y), C("c1" if v < 0.18 else "c3" if v > 0.85 else "c2"))
    rect(img, 0, 0, T - 1, 3, C("w0"))  # shadow under the cap
    if post:
        rect(img, 13, 0, 18, T - 1, C("w2"))
        rect(img, 13, 0, 13, T - 1, C("w3"))
        rect(img, 18, 0, 18, T - 1, C("w1"))
    return img


def lower_wall() -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, T - 1, C("w3"))
    rect(img, 0, 0, T - 1, 3, C("w4"))
    rect(img, 0, 4, T - 1, 4, C("w2"))
    for x in (0, 16):
        rect(img, x + 2, 8, x + 13, 26, C("w2"))
        rect(img, x + 3, 9, x + 12, 25, C("w3"))
        rect(img, x + 3, 9, x + 12, 9, C("w4"))
    rect(img, 0, 28, T - 1, T - 1, C("w1"))
    return img


def side_wall(left: bool) -> Image.Image:
    img = new(T, T)
    nz = TileNoise(91, T, 4)
    for y in range(T):
        for x in range(T):
            v = fractal([nz], x, y)
            img.putpixel((x, y), C("s1" if v < 0.4 else "s2"))
    edge = T - 4 if left else 0
    rect(img, edge, 0, edge + 3, T - 1, C("w1"))
    rect(img, edge + (3 if left else 0), 0, edge + (3 if left else 0), T - 1, C("w0"))
    return img


def front_wall() -> Image.Image:
    img = new(T, T)
    nz = TileNoise(92, T, 4)
    for y in range(T):
        for x in range(T):
            v = fractal([nz], x, y)
            img.putpixel((x, y), C("s1" if v < 0.4 else "s2"))
    rect(img, 0, 0, T - 1, 3, C("w1"))
    rect(img, 0, 0, T - 1, 0, C("w0"))
    return img


def doormat(base: Image.Image) -> Image.Image:
    img = base.copy()
    rect(img, 3, 6, 28, 27, C("r1"))
    rect(img, 5, 8, 26, 25, C("r2"))
    for x in range(5, 27, 3):
        rect(img, x, 8, x, 25, C("r1"))
    return img


def shadowed(base: Image.Image) -> Image.Image:
    img = base.copy()
    for y in range(10):
        for x in range(T):
            r, g, b, a = img.getpixel((x, y))
            k = 0.55 + 0.045 * y
            img.putpixel((x, y), (int(r * k), int(g * k), int(b * k), a))
    return img


# ------------------------------------------------------------------ furniture
def hearth() -> Image.Image:
    w, h = 96, 128
    img = new(w, h)
    b = new(w, h)
    # chimney breast (stone blocks) on the wall
    rect(b, 8, 0, 87, 127, C("s2"))
    for y in range(0, 128, 8):
        rect(b, 8, y, 87, y, C("s1"))
        for x in range(8 + (8 if (y // 8) % 2 else 0), 88, 16):
            rect(b, x, y, x, y + 7, C("s1"))
            put(b, x + 1, y + 1, C("s3"))
    rect(b, 8, 0, 9, 127, C("s3"))
    rect(b, 86, 0, 87, 127, C("s1"))
    # mantel
    rect(b, 2, 58, 93, 65, C("w3"))
    rect(b, 2, 58, 93, 58, C("w5"))
    rect(b, 2, 65, 93, 65, C("w1"))
    for x, c in ((14, "r2"), (22, "t1"), (64, "f3"), (74, "m2")):
        rect(b, x, 50, x + 5, 57, C(c))
        rect(b, x + 1, 48, x + 4, 49, C("c3"))
        put(b, x + 1, 52, C("c4"))
    # firebox arch
    for y in range(72, 122):
        for x in range(20, 76):
            dx = x - 47.5
            if y < 86 and dx * dx + ((y - 86) * 2.0) ** 2 > 28 ** 2:
                continue
            b.putpixel((x, y), C("outline"))
    for y in range(76, 122):
        for x in range(24, 72):
            dx = x - 47.5
            if y < 88 and dx * dx + ((y - 88) * 2.0) ** 2 > 24 ** 2:
                continue
            glow = (y - 76) / 46
            b.putpixel((x, y), C("f0" if glow < 0.5 else "f1"))
    # hearth stone apron
    rect(b, 4, 120, 91, 127, C("s3"))
    rect(b, 4, 120, 91, 120, C("s4"))
    for x in range(4, 92, 11):
        rect(b, x, 121, x, 127, C("s2"))
    img.alpha_composite(outline(b))
    return img


def fire_frames() -> Image.Image:
    sheet = new(40 * 3, 32)
    for f in range(3):
        img = new(40, 32)
        rng = random.Random(40 + f)
        rect(img, 6, 26, 33, 29, C("w1"))      # logs
        rect(img, 8, 24, 31, 25, C("w2"))
        for x in range(8, 32):
            hgt = int(10 + 8 * abs(((x + f * 3) % 9) - 4) / 4 + rng.randint(0, 3))
            for k in range(hgt):
                y = 25 - k
                t = k / hgt
                c = "f5" if t < 0.25 and 14 < x < 26 else "f4" if t < 0.45 else "f3" if t < 0.7 else "f2"
                put(img, x, y, C(c))
        sheet.alpha_composite(img, (f * 40, 0))
    return sheet


def cauldron() -> Image.Image:
    img = new(36, 32)
    soft_shadow(img, 18, 29, 14, 3)
    pot = blob(36, 32, [(18, 18, 12)])
    for y in range(0, 10):
        for x in range(36):
            pot.putpixel((x, y), (0, 0, 0, 0))
    shade_by_light(pot, ["s0", "s0", "s1", "s2", "s3"])
    rect(pot, 6, 9, 29, 11, C("s2"))           # rim
    rect(pot, 8, 10, 27, 10, C("t2"))          # bubbling surface hint
    put(pot, 12, 10, C("t3"))
    put(pot, 22, 10, C("t3"))
    rect(pot, 9, 28, 11, 30, C("s1"))           # feet
    rect(pot, 24, 28, 26, 30, C("s1"))
    img.alpha_composite(outline(pot))
    return img


def counter() -> Image.Image:
    w, h = 160, 56
    img = new(w, h)
    soft_shadow(img, 80, 52, 78, 4)
    b = new(w, h)
    rect(b, 0, 8, w - 1, 23, C("w4"))           # top surface
    rect(b, 0, 8, w - 1, 9, C("w5"))
    for x in range(0, w, 20):
        rect(b, x, 10, x, 23, C("w3"))
    rect(b, 0, 24, w - 1, 49, C("w3"))          # front panel
    rect(b, 0, 24, w - 1, 25, C("w1"))
    for x in range(4, w - 8, 32):
        rect(b, x, 29, x + 25, 45, C("w2"))
        rect(b, x + 1, 30, x + 24, 44, C("w3"))
        rect(b, x + 1, 30, x + 24, 30, C("w4"))
    rect(b, 0, 48, w - 1, 49, C("w1"))
    img.alpha_composite(outline(b))
    return img


def table() -> Image.Image:
    w, h = 52, 44
    img = new(w, h)
    soft_shadow(img, 26, 40, 20, 4)
    b = new(w, h)
    rect(b, 22, 22, 29, 39, C("w2"))
    rect(b, 18, 37, 33, 39, C("w2"))
    top = blob(w, h, [(26, 16, 0)])
    for y in range(4, 28):
        for x in range(2, 50):
            if ((x + 0.5 - 26) / 24) ** 2 + ((y + 0.5 - 15) / 11) ** 2 <= 1:
                top.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(top, ["w2", "w3", "w4", "w4", "w5", "w6"])
    b.alpha_composite(top)
    rect(b, 4, 21, 47, 22, C("w2"))
    img.alpha_composite(outline(b))
    return img


def stool() -> Image.Image:
    img = new(22, 22)
    soft_shadow(img, 11, 19, 8, 2)
    b = new(22, 22)
    rect(b, 5, 10, 6, 18, C("w2"))
    rect(b, 15, 10, 16, 18, C("w2"))
    for y in range(3, 12):
        for x in range(2, 20):
            if ((x + 0.5 - 11) / 9) ** 2 + ((y + 0.5 - 7) / 4.5) ** 2 <= 1:
                b.putpixel((x, y), C("w5" if y < 7 else "w4"))
    img.alpha_composite(outline(b))
    return img


def barrel() -> Image.Image:
    img = new(28, 36)
    soft_shadow(img, 14, 33, 12, 3)
    b = blob(28, 36, [(14, 18, 0)])
    for y in range(4, 33):
        bulge = 1 - abs((y - 18) / 16) ** 2
        half = int(9 + 3 * bulge)
        for x in range(14 - half, 14 + half):
            b.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(b, ["w1", "w2", "w3", "w4", "w5"])
    for y in (9, 26):
        for x in range(28):
            if b.getpixel((x, y))[3]:
                b.putpixel((x, y), C("s1"))
    for y in range(4, 7):
        for x in range(28):
            if b.getpixel((x, y))[3]:
                b.putpixel((x, y), C("w5" if y < 6 else "w2"))
    img.alpha_composite(outline(b))
    return img


def crate() -> Image.Image:
    img = new(30, 30)
    soft_shadow(img, 15, 27, 13, 3)
    b = new(30, 30)
    rect(b, 2, 2, 27, 26, C("w4"))
    rect(b, 2, 2, 27, 7, C("w5"))
    rect(b, 2, 8, 27, 8, C("w2"))
    for x in (2, 25):
        rect(b, x, 8, x + 2, 26, C("w3"))
    for i in range(18):
        put(b, 5 + i, 25 - i, C("w3"))
        put(b, 6 + i, 25 - i, C("w3"))
    img.alpha_composite(outline(b))
    return img


def shelf() -> Image.Image:
    img = new(64, 44)
    b = new(64, 44)
    for y in (18, 40):
        rect(b, 0, y, 63, y + 3, C("w3"))
        rect(b, 0, y, 63, y, C("w5"))
    rect(b, 4, 22, 6, 30, C("w1"))
    rect(b, 57, 22, 59, 30, C("w1"))
    rng = random.Random(5)
    x = 3
    for row_y in (17, 39):
        x = 3
        while x < 58:
            c = rng.choice(["r2", "t1", "f3", "m2", "g3", "c3", "b3"])
            hgt = rng.randint(7, 12)
            wid = rng.randint(4, 7)
            rect(b, x, row_y - hgt, x + wid - 1, row_y, C(c))
            rect(b, x + 1, row_y - hgt - 2, x + wid - 2, row_y - hgt - 1, C("w2"))
            put(b, x + 1, row_y - hgt + 2, C("c4"))
            x += wid + rng.randint(1, 3)
    img.alpha_composite(outline(b))
    return img


def window() -> Image.Image:
    img = new(52, 44)
    b = new(52, 44)
    rect(b, 0, 0, 51, 43, C("w1"))
    rect(b, 3, 3, 48, 36, C("b4"))
    rect(b, 3, 3, 48, 12, C("b5"))
    for x in range(3, 49):          # treetops outside
        top = 26 + int(4 * abs(((x * 7) % 11) - 5) / 5)
        rect(b, x, top, x, 36, C("g3" if (x // 5) % 2 else "g4"))
    rect(b, 24, 3, 27, 36, C("w2"))
    rect(b, 3, 18, 48, 20, C("w2"))
    rect(b, -1, 37, 52, 43, C("w3"))
    rect(b, 0, 37, 51, 37, C("w5"))
    img.alpha_composite(outline(b))
    return img


def notice_board() -> Image.Image:
    img = new(48, 44)
    b = new(48, 44)
    rect(b, 0, 0, 47, 39, C("w2"))
    rect(b, 3, 3, 44, 36, C("d3"))
    for (x, y, w, h, c) in ((6, 6, 14, 12, "c3"), (24, 5, 16, 14, "c4"), (8, 21, 16, 12, "c4"), (28, 22, 12, 11, "c2")):
        rect(b, x, y, x + w - 1, y + h - 1, C(c))
        for ly in range(y + 3, y + h - 2, 3):
            rect(b, x + 2, ly, x + w - 3, ly, C("c0"))
        put(b, x + w // 2, y + 1, C("r3"))
    rect(b, 26, 8, 37, 9, C("f2"))      # highlighted notice: the satchel offer
    img.alpha_composite(outline(b))
    return img


def sign(label: str, color: str) -> Image.Image:
    img = new(48, 44)
    soft_shadow(img, 24, 41, 18, 3)
    b = new(48, 44)
    for i in range(14):  # A-frame legs
        put(b, 7 - i // 4, 26 + i, C("w2"))
        put(b, 40 + i // 4, 26 + i, C("w2"))
    rect(b, 3, 4, 44, 29, C("w3"))
    rect(b, 5, 6, 42, 27, C("s0"))
    tw = text_width(label)
    text(b, 24 - tw // 2, 10, label, C(color))
    rect(b, 9, 21, 38, 21, C("s1"))
    img.alpha_composite(outline(b))
    return img


def pantry_chest() -> Image.Image:
    img = new(36, 32)
    soft_shadow(img, 18, 29, 16, 3)
    b = new(36, 32)
    rect(b, 2, 6, 33, 27, C("w3"))
    rect(b, 2, 6, 33, 12, C("w4"))
    rect(b, 2, 6, 33, 6, C("w5"))
    rect(b, 2, 13, 33, 13, C("w1"))
    for x in (6, 28):
        rect(b, x, 6, x + 1, 27, C("s2"))
    rect(b, 16, 11, 19, 16, C("f4"))
    put(b, 17, 14, C("w1"))
    img.alpha_composite(outline(b))
    return img


def rug() -> Image.Image:
    img = new(160, 96)
    for y in range(96):
        for x in range(160):
            border = x < 6 or x > 153 or y < 6 or y > 89
            inner = 12 < x < 147 and 12 < y < 83
            c = "r1" if border else ("r2" if inner else "f3")
            if inner and ((x // 8 + y // 8) % 2 == 0) and 20 < x < 139 and 20 < y < 75:
                c = "r3" if (x // 8) % 3 == 0 else "r2"
            img.putpixel((x, y), C(c, 230))
    return img


def plant() -> Image.Image:
    img = new(24, 34)
    soft_shadow(img, 12, 31, 9, 2)
    b = new(24, 34)
    rect(b, 6, 20, 17, 30, C("f1"))
    rect(b, 5, 20, 18, 22, C("f2"))
    leaves = blob(24, 34, [(12, 12, 7), (6, 15, 5), (18, 15, 5), (12, 6, 5)])
    shade_by_light(leaves, ["g1", "g2", "g3", "g4", "g5"])
    b.alpha_composite(leaves)
    img.alpha_composite(outline(b))
    return img


def wall_lantern() -> Image.Image:
    img = new(14, 22)
    b = new(14, 22)
    rect(b, 6, 0, 7, 3, C("s1"))
    rect(b, 2, 4, 11, 16, C("s1"))
    rect(b, 4, 6, 9, 14, C("f4"))
    rect(b, 5, 8, 8, 12, C("f5"))
    rect(b, 1, 17, 12, 18, C("s2"))
    img.alpha_composite(outline(b))
    return img


def main() -> None:
    scratch = ROOT / ".godot" / "art_previews"
    scratch.mkdir(parents=True, exist_ok=True)
    floors = [floor(i) for i in range(4)]
    tiles = floors + [shadowed(floors[0]), doormat(floors[1]), new(T, T), new(T, T),
                      wall_cap(), upper_wall(False), upper_wall(True), lower_wall(),
                      side_wall(True), side_wall(False), front_wall(), new(T, T)]
    atlas = new(T * 8, T * 2)
    for i, tile in enumerate(tiles):
        atlas.alpha_composite(tile, ((i % 8) * T, (i // 8) * T))
    save(atlas, "tiles/tavern_tiles.png")
    preview(atlas, scratch / "tavern_tiles.png", scale=3)
    props = {
        "props/hearth.png": hearth(), "props/fire.png": fire_frames(), "props/cauldron.png": cauldron(),
        "props/counter.png": counter(), "props/table.png": table(), "props/stool.png": stool(),
        "props/barrel.png": barrel(), "props/crate.png": crate(), "props/shelf.png": shelf(),
        "props/window.png": window(), "props/notice_board.png": notice_board(),
        "props/sign_open.png": sign("OPEN", "g5"), "props/sign_closed.png": sign("CLOSED", "r3"),
        "props/pantry_chest.png": pantry_chest(), "props/rug.png": rug(), "props/plant.png": plant(),
        "props/wall_lantern.png": wall_lantern(),
    }
    for rel, img in props.items():
        save(img, rel)
        preview(img, scratch / rel.replace("/", "_"), scale=3)
    print("wrote tavern tiles and", len(props), "props")


if __name__ == "__main__":
    main()
