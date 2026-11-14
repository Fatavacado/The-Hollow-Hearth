"""Copperfern benchmark forest kit (v001): dual-grid terrain atlas, decor, round broadleaf tree, bush and
two gatherable ingredients (glowcap, moonberry) with full/picked states. Native pixels, light upper left.

Terrain atlas layout matches scripts/world/dual_grid.gd (32x32 tiles, 16 columns):
  row 0 grass<->path transitions (column = corner mask TL=1 TR=2 BL=4 BR=8)
  row 1 unused (water is not part of this benchmark) - transparent
  row 2 grass<->forest-mass transitions
  row 3 pure variants: 0-3 grass, 4-7 path, 12-15 forest mass
"""
from __future__ import annotations

import math
import random

from PIL import Image

from cf_palette import C, outline

T = 32


def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def put(img: Image.Image, x: int, y: int, color, wrap: bool = False) -> None:
    if wrap:
        x, y = x % img.width, y % img.height
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


# ----------------------------------------------------------------------------- leaf clumps
def clump(img: Image.Image, cx: float, cy: float, r: float, wrap: bool = False, golden: bool = True,
          tone: int = 0) -> None:
    """One fluffy leaf clump lit from above-left, built in bands: golden crest on the lit rim, bright
    upper body, mid, shaded underside and a dark separating rim. `tone` -1 darkens a back-tier clump.
    The silhouette is scalloped into leaf lobes; sparse sparkles keep large clumps from going flat."""
    ramp = [C("leaf", i) for i in range(6)]

    def shade(i: int):
        return ramp[max(0, min(5, i + tone))]

    lobes = 6 + int(r) // 3
    for y in range(int(cy - r) - 2, int(cy + r) + 2):
        for x in range(int(cx - r) - 2, int(cx + r) + 2):
            dx, dy = x + 0.5 - cx, y + 0.5 - cy
            d = math.hypot(dx, dy)
            ang = math.atan2(dy, dx)
            rr = r * (1.0 + 0.11 * math.cos(ang * lobes + cx * 0.9 + cy * 0.3))
            if d > rr:
                continue
            ny = dy / rr  # -1 top ... +1 bottom
            nx = dx / rr
            lit = -(0.45 * nx + 0.9 * ny)  # mostly from above, slightly left
            rim = d > rr - 1.1
            if rim and lit < 0.1:
                col = shade(0)
            elif rim and lit >= 0.1:
                col = shade(5) if golden else shade(4)
            elif lit > 0.55:
                col = shade(5) if golden and d > rr - 2.6 else shade(4)
            elif lit > 0.15:
                col = shade(4)
            elif lit > -0.3:
                col = shade(3)
            elif lit > -0.65:
                col = shade(2)
            else:
                col = shade(1)
            put(img, x, y, col, wrap)
    rng = random.Random(int(cx * 31 + cy * 17 + r * 7))
    for _ in range(max(1, int(r * 0.8))):  # leaf sparkles (lit) and notches (shade)
        a = rng.uniform(math.pi * 1.05, math.pi * 1.7)
        rad = rng.uniform(r * 0.2, r * 0.75)
        put(img, int(cx + math.cos(a) * rad), int(cy + math.sin(a) * rad), shade(5 if golden else 4), wrap)
        a2 = rng.uniform(0.1, math.pi * 0.9)
        rad2 = rng.uniform(r * 0.3, r * 0.8)
        put(img, int(cx + math.cos(a2) * rad2), int(cy + math.sin(a2) * rad2), shade(1), wrap)


def soft_shadow(img: Image.Image, cx: float, cy: float, rx: float, ry: float, alpha: int = 90) -> None:
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1:
                put(img, x, y, (34, 74, 34, alpha))


# ----------------------------------------------------------------------------- terrain textures
def grass_tile(variant: int) -> Image.Image:
    img = new(T, T)
    base, mid, light, dark = C("grass", 2), C("grass", 3), C("grass", 4), C("grass", 1)
    for y in range(T):
        for x in range(T):
            img.putpixel((x, y), base)
    rng = random.Random(10 + variant)
    # soft lighter patches (2x2 clusters) - quiet, low contrast
    for _ in range(10):
        x, y = rng.randrange(T), rng.randrange(T)
        for dx, dy in ((0, 0), (1, 0), (0, 1)):
            put(img, x + dx, y + dy, mid, wrap=True)
    # tufts: a small "v" of blades with a darker root pixel
    spots = [(4, 6), (20, 3), (12, 15), (27, 18), (6, 25), (18, 27)]
    for i, (x, y) in enumerate(spots):
        x += rng.randint(-2, 2)
        y += rng.randint(-2, 2)
        put(img, x, y + 2, dark, True)
        put(img, x + 1, y + 2, dark, True)
        put(img, x - 1, y, mid, True)
        put(img, x, y + 1, mid, True)
        put(img, x + 1, y + 1, mid, True)
        put(img, x + 2, y, light if i % 2 else mid, True)
        put(img, x, y - 1 + (i % 2), light, True)
    if variant >= 2:  # a few variants carry a clover or tiny flower, kept away from edges
        x, y = rng.randrange(6, 24), rng.randrange(6, 24)
        flower = C("flower", 2) if variant == 2 else C("flower", 1)
        put(img, x, y, flower)
        put(img, x + 1, y + 1, flower)
        put(img, x + 1, y, C("grass", 4))
        put(img, x, y + 1, dark)
    return img


def path_tile(variant: int) -> Image.Image:
    img = new(T, T)
    base, light, shade, deep, pale = C("path", 2), C("path", 3), C("path", 1), C("path", 0), C("path", 4)
    for y in range(T):
        for x in range(T):
            img.putpixel((x, y), base)
    rng = random.Random(40 + variant)
    for _ in range(9):  # sun-bleached patches
        x, y = rng.randrange(T), rng.randrange(T)
        for dx in range(rng.randint(2, 4)):
            put(img, x + dx, y, light, True)
        put(img, x + 1, y + 1, light, True)
    for _ in range(5 + variant):  # pebbles with a lit top and a small shadow
        x, y = rng.randrange(3, T - 3), rng.randrange(3, T - 3)
        put(img, x, y, shade)
        put(img, x + 1, y, shade)
        put(img, x, y - 1, pale)
        put(img, x + 1, y + 1, deep)
    return img


def forest_mass_tile() -> Image.Image:
    """Dense tree-crown backdrop for impassable forest: a back tier of dark crowns with brighter
    crowns over it, irregularly placed so the 32px repeat does not read as a pattern."""
    img = new(T, T)
    for y in range(T):
        for x in range(T):
            img.putpixel((x, y), C("leaf", 0))
    back = [(6, 6, 8.0), (22, 3, 7.5), (30, 19, 8.0), (13, 20, 7.5), (2, 27, 7.0)]
    front = [(15, 9, 6.5), (27, 9, 5.5), (5, 17, 6.0), (22, 24, 6.5), (11, 30, 5.5), (31, 30, 5.0)]
    for x, y, r in back:
        clump(img, x, y, r, wrap=True, golden=False, tone=-2)
    for i, (x, y, r) in enumerate(front):
        clump(img, x, y, r, wrap=True, golden=i in (0, 3), tone=-1)
    return img


# ----------------------------------------------------------------------------- dual-grid transitions
def _field_factory(mask: int, seed: int, amp: float, block: int = 2):
    tl, tr, bl, br = [(mask >> i) & 1 for i in range(4)]
    rng = random.Random(seed)
    cells = T // 8
    grid = [[rng.random() for _ in range(cells)] for _ in range(cells)]

    def noise(x: float, y: float) -> float:  # tileable value noise, 8 px cells
        gx, gy = x / 8.0, y / 8.0
        x0, y0 = int(math.floor(gx)), int(math.floor(gy))
        fx, fy = gx - x0, gy - y0
        fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)

        def g(i, j):
            return grid[j % cells][i % cells]
        top = g(x0, y0) * (1 - fx) + g(x0 + 1, y0) * fx
        bot = g(x0, y0 + 1) * (1 - fx) + g(x0 + 1, y0 + 1) * fx
        return top * (1 - fy) + bot * fy

    def inside(x: int, y: int) -> bool:
        # evaluate on 2x2 blocks for a stepped, clustered edge
        bx, by = (x // block) * block + block / 2.0, (y // block) * block + block / 2.0
        u, v = bx / T, by / T
        f = (tl * (1 - u) + tr * u) * (1 - v) + (bl * (1 - u) + br * u) * v
        return f + (noise(bx % T, by % T) - 0.5) * amp > 0.5

    return inside


def path_transition(mask: int, grass: Image.Image, path: Image.Image) -> Image.Image:
    inside = _field_factory(mask, 1001, 0.42)
    img = new(T, T)
    for y in range(T):
        for x in range(T):
            if inside(x, y):
                col = path.getpixel((x, y))
                if not inside(x, y - 1) or not inside(x, y - 2):
                    col = C("path", 1) if not inside(x, y - 1) else C("path", 2)  # sunken lip
                elif not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y + 1)):
                    col = C("path", 1)
            else:
                col = grass.getpixel((x, y))
                if inside(x, y + 1):
                    col = C("grass", 3) if (x // 2) % 2 else C("grass", 4)  # grass overhang tips
                elif inside(x - 1, y) or inside(x + 1, y):
                    col = C("grass", 3)
            img.putpixel((x, y), col)
    return img


def mass_transition(mask: int, grass: Image.Image, mass: Image.Image) -> Image.Image:
    inside = _field_factory(mask, 3003, 0.55)
    img = new(T, T)
    for y in range(T):
        for x in range(T):
            if inside(x, y):
                col = mass.getpixel((x, y))
                if not inside(x, y + 1):
                    col = C("leaf", 0)
                elif not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y - 1)):
                    col = C("leaf", 2) if not inside(x, y - 1) else C("leaf", 1)
            else:
                col = grass.getpixel((x, y))
                if inside(x, y - 1) or inside(x, y - 2):
                    col = C("grass", 0)
                elif inside(x, y - 3) or inside(x, y - 4):
                    col = C("grass", 1)
            img.putpixel((x, y), col)
    return img


def terrain_atlas() -> Image.Image:
    grass = grass_tile(0)
    path = path_tile(0)
    mass = forest_mass_tile()
    atlas = new(T * 16, T * 4)
    for mask in range(16):
        atlas.alpha_composite(path_transition(mask, grass, path), (mask * T, 0))
        atlas.alpha_composite(mass_transition(mask, grass, mass), (mask * T, 2 * T))
    for i in range(4):
        atlas.alpha_composite(grass_tile(i), (i * T, 3 * T))
        atlas.alpha_composite(path_tile(i), ((4 + i) * T, 3 * T))
        atlas.alpha_composite(mass, ((12 + i) * T, 3 * T))
    return atlas


# ----------------------------------------------------------------------------- decor (transparent tiles)
def decor_atlas() -> Image.Image:
    tiles = []
    # 0-2: flower clusters (white daisy, buttercup, coral)
    for k, (petal, centre) in enumerate(((C("flower", 2), C("flower", 1)), (C("flower", 1), C("brass", 2)),
                                         (C("flower", 0), C("flower", 1)))):
        img = new(T, T)
        rng = random.Random(500 + k)
        for _ in range(3):
            x, y = rng.randrange(7, 25), rng.randrange(8, 24)
            put(img, x, y + 2, C("grass", 1))
            put(img, x, y + 3, C("grass", 1))
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                put(img, x + dx, y + dy, petal)
            put(img, x, y, centre)
            put(img, x + 1, y + 1, C("grass", 0))
        tiles.append(img)
    # 3: tall grass tuft
    img = new(T, T)
    for i, h in enumerate((5, 8, 6, 9, 5)):
        x = 11 + i * 2
        for k in range(h):
            put(img, x + (1 if k > h - 3 and i % 2 else 0), 25 - k, C("grass", 4 if k > h - 3 else 3))
        put(img, x, 26, C("grass", 0))
    tiles.append(img)
    # 4: lavender sprigs
    img = new(T, T)
    for i in range(3):
        x = 12 + i * 4
        for k in range(6):
            put(img, x, 25 - k, C("grass", 1))
        for k in range(3):
            put(img, x, 18 - k, C("flower", 3))
            put(img, x + 1, 19 - k, C("berry", 2))
    tiles.append(img)
    # 5: small stones
    img = new(T, T)
    for x, y in ((11, 18), (17, 20)):
        for dx in range(3):
            put(img, x + dx, y, C("stone", 2))
            put(img, x + dx, y - 1, C("stone", 3))
        put(img, x, y + 1, C("grass", 0))
        put(img, x + 1, y + 1, C("grass", 0))
        put(img, x + 2, y + 1, C("grass", 0))
    tiles.append(img)
    atlas = new(T * len(tiles), T)
    for i, t in enumerate(tiles):
        atlas.alpha_composite(t, (i * T, 0))
    return atlas


# ----------------------------------------------------------------------------- props
def tree() -> Image.Image:
    """Round broadleaf tree: dome of leaf clumps over a short flared trunk. 80x100, foot row 94."""
    w, h = 80, 100
    img = new(w, h)
    soft_shadow(img, 40, 94, 22, 5, 110)
    trunk = new(w, h)
    for y in range(66, 95):
        half = 5 + (max(0, y - 86) // 2)
        for x in range(40 - half, 40 + half):
            t = (x - (40 - half)) / (2 * half)
            col = C("bark", 3) if t < 0.25 else C("bark", 2) if t < 0.6 else C("bark", 1)
            trunk.putpixel((x, y), col)
    for x, y in ((38, 72), (39, 73), (41, 80), (42, 81), (37, 86)):  # bark grooves
        trunk.putpixel((x, y), C("bark", 0))
    img.alpha_composite(outline(trunk))
    canopy = new(w, h)
    back = [(28, 20, 11), (52, 20, 11), (16, 40, 10), (64, 40, 10), (40, 30, 13), (40, 58, 11)]
    front = [(40, 14, 11), (25, 31, 10), (55, 31, 10), (32, 46, 10.5), (48, 45, 10.5),
             (20, 52, 8.5), (60, 52, 8.5), (40, 60, 9)]
    for cx, cy, r in back:
        clump(canopy, cx, cy, r, tone=-1)
    for cx, cy, r in front:
        clump(canopy, cx, cy, r)
    img.alpha_composite(outline(canopy))
    return img


def bush(berries: bool = False) -> Image.Image:
    img = new(36, 30)
    soft_shadow(img, 18, 26, 14, 3, 110)
    b = new(36, 30)
    for cx, cy, r in ((11, 16, 7), (25, 16, 7), (18, 11, 8), (18, 19, 7)):
        clump(b, cx, cy, r)
    img.alpha_composite(outline(b))
    if berries:
        # clusters of three silver-blue berries with a dark rim: they must read by value, not just hue
        for x, y in ((8, 11), (16, 6), (23, 10), (11, 18), (20, 16), (26, 17)):
            for bx, by in ((x, y), (x + 2, y + 1), (x, y + 2)):
                for dx, dy in ((-1, 0), (2, 0), (0, -1), (1, -1), (0, 2), (1, 2), (-1, 1), (2, 1)):
                    if img.getpixel((bx + dx, by + dy))[3]:
                        img.putpixel((bx + dx, by + dy), C("berry", 0))
            for bx, by in ((x, y), (x + 2, y + 1), (x, y + 2)):
                img.putpixel((bx, by), C("berry", 3))
                img.putpixel((bx + 1, by), C("berry", 2))
                img.putpixel((bx, by + 1), C("berry", 2))
                img.putpixel((bx + 1, by + 1), C("berry", 1))
    return img


def glowcap(full: bool) -> Image.Image:
    img = new(32, 28)
    soft_shadow(img, 16, 24, 12, 3, 100)
    if not full:
        stubs = new(32, 28)
        for x in (10, 17, 23):
            for y in (21, 22, 23):
                stubs.putpixel((x, y), C("stem", 1))
                stubs.putpixel((x + 1, y), C("stem", 0))
        img.alpha_composite(outline(stubs))
        return img
    for x, y, r in ((10, 23, 4), (19, 24, 5.5), (25, 22, 3.5)):
        part = new(32, 28)
        stem_top = int(y - r - 1)
        for yy in range(stem_top, y + 1):
            part.putpixel((x - 1, yy), C("stem", 2))
            part.putpixel((x, yy), C("stem", 1))
            part.putpixel((x + 1, yy), C("stem", 0))
        cy = stem_top
        for yy in range(int(cy - r), cy + 2):
            for xx in range(int(x - r - 1), int(x + r + 2)):
                dx, dy = xx + 0.5 - x, (yy + 0.5 - cy) * 1.5
                if dx * dx + dy * dy <= (r + 0.6) ** 2 and yy <= cy + 1:
                    lit = -(dx + dy) / (r + 0.6)
                    k = 3 if lit > 0.6 else 2 if lit > -0.1 else 1 if lit > -0.6 else 0
                    part.putpixel((xx, yy), C("cap", k))
        part.putpixel((x - 1, int(cy - r * 0.5)), C("stem", 2))  # cap spots
        part.putpixel((x + 1, cy - 1), C("stem", 2))
        img.alpha_composite(outline(part, C("cap", 0)))
    for x, y in ((6, 15), (27, 13), (15, 12)):  # floating glow motes
        img.putpixel((x, y), C("cap", 3, 220))
    return img


def build() -> dict[str, Image.Image]:
    return {
        "forest_terrain_v001.png": terrain_atlas(),
        "forest_decor_v001.png": decor_atlas(),
        "tree_round_v001.png": tree(),
        "bush_v001.png": bush(False),
        "moonberry_full_v001.png": bush(True),
        "moonberry_empty_v001.png": bush(False),
        "glowcap_full_v001.png": glowcap(True),
        "glowcap_empty_v001.png": glowcap(False),
    }
