"""Copperfern benchmark tavern kit (v001): floor/wall tiles, serving counter, table, chair and the
cooking station (iron stove + copper pot + fire frames). High top-down camera: big visible tops,
shallow front faces. Light from the upper left; warm only locally at the stove.

Tile atlas `tavern_tiles_v001.png` (32x32, 8 columns):
  row 0: planks 0-3 | planks in the back wall's shadow | flagstone 0-1 | doormat planks
  row 1: wall upper | wall upper + post | wall lower (wainscot) | wall lower + post |
         wall top left | wall top right | front wall top | (empty)
"""
from __future__ import annotations

import random

from PIL import Image

from cf_palette import C, outline

T = 32


def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def rect(img: Image.Image, x0: int, y0: int, x1: int, y1: int, color) -> None:
    for y in range(max(0, y0), min(img.height, y1 + 1)):
        for x in range(max(0, x0), min(img.width, x1 + 1)):
            img.putpixel((x, y), color)


def put(img: Image.Image, x: int, y: int, color) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def soft_shadow(img: Image.Image, x0: int, y0: int, x1: int, y1: int, alpha: int = 70) -> None:
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < img.width and 0 <= y < img.height and img.getpixel((x, y))[3] == 0:
                img.putpixel((x, y), (92, 50, 22, alpha))


# ----------------------------------------------------------------------------- tiles
def planks(variant: int) -> Image.Image:
    img = new(T, T)
    rng = random.Random(70 + variant)
    joints = [rng.randrange(4, 28) for _ in range(4)]
    for row in range(4):
        y0 = row * 8
        rect(img, 0, y0, T - 1, y0 + 7, C("wood", 3))                    # one quiet board tone
        rect(img, 0, y0 + 7, T - 1, y0 + 7, C("wood", 2))                # seam
        gx, gy = rng.randrange(0, T - 10), y0 + rng.randrange(2, 6)        # one soft grain streak
        rect(img, gx, gy, gx + rng.randrange(5, 10), gy, C("wood", 4))
        if rng.random() < 0.6:
            jx = joints[row]
            rect(img, jx, y0, jx, y0 + 6, C("wood", 2))                  # occasional board end
        if variant == 3 and row == 1:
            put(img, (joints[row] + 9) % T, y0 + 3, C("wood", 1))        # a rare knot
    return img


def shadowed(tile: Image.Image, rows: int = 7) -> Image.Image:
    img = tile.copy()
    for y in range(rows):
        k = 0.72 + 0.04 * y
        for x in range(T):
            r, g, b, a = img.getpixel((x, y))
            img.putpixel((x, y), (int(r * k), int(g * k), int(b * k * 0.98), a))
    return img


def flagstone(variant: int) -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, T - 1, C("stone", 1))  # mortar
    stones = [(1, 1, 14, 9), (16, 1, 30, 12), (1, 11, 9, 22), (11, 11, 22, 21), (24, 14, 30, 30),
              (1, 24, 13, 30), (15, 23, 22, 30)]
    if variant:
        stones = [(1, 1, 10, 13), (12, 1, 30, 9), (12, 11, 21, 21), (1, 15, 10, 30), (23, 11, 30, 21),
                  (12, 23, 30, 30)]
    for x0, y0, x1, y1 in stones:
        rect(img, x0, y0, x1, y1, C("stone", 2))
        rect(img, x0, y0, x1, y0, C("stone", 3))
        rect(img, x0, y0, x0, y1, C("stone", 3))
        rect(img, x1, y0 + 1, x1, y1, C("stone", 1))
        put(img, x0 + 1, y0 + 1, C("stone", 3))
    return img


def doormat(base: Image.Image) -> Image.Image:
    img = base.copy()
    rect(img, 2, 5, 29, 28, C("teal", 1))
    rect(img, 4, 7, 27, 26, C("teal", 2))
    for x in range(5, 27, 4):
        rect(img, x, 8, x, 25, C("teal", 1))
    rect(img, 2, 28, 29, 28, C("teal", 0))
    return img


def wall_upper(post: bool) -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, T - 1, C("plaster", 1))
    rng = random.Random(5 if post else 6)
    for _ in range(14):  # gentle plaster texture
        x, y = rng.randrange(T), rng.randrange(9, T)
        put(img, x, y, C("plaster", rng.choice((0, 2))))
    rect(img, 0, 0, T - 1, 5, C("timber", 1))      # ceiling beam (seen from above)
    rect(img, 0, 0, T - 1, 1, C("timber", 2))
    rect(img, 0, 6, T - 1, 7, C("plaster", 0))     # beam shadow on plaster
    if post:
        rect(img, 12, 6, 19, T - 1, C("timber", 1))
        rect(img, 12, 6, 13, T - 1, C("timber", 2))
        rect(img, 19, 6, 19, T - 1, C("timber", 0))
    return img


def wall_lower(post: bool) -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, 9, C("plaster", 1))
    rect(img, 0, 10, T - 1, 11, C("teal", 3))       # wainscot cap rail
    rect(img, 0, 12, T - 1, 27, C("teal", 2))
    for x0 in (2, 18):                                # panels
        rect(img, x0, 14, x0 + 11, 25, C("teal", 1))
        rect(img, x0 + 1, 15, x0 + 10, 24, C("teal", 2))
        rect(img, x0 + 1, 15, x0 + 10, 15, C("teal", 3))
    rect(img, 0, 28, T - 1, 31, C("timber", 1))     # baseboard
    rect(img, 0, 28, T - 1, 28, C("timber", 2))
    if post:
        rect(img, 12, 0, 19, 27, C("timber", 1))
        rect(img, 12, 0, 13, 27, C("timber", 2))
        rect(img, 19, 0, 19, 27, C("timber", 0))
    return img


def wall_top(side: str) -> Image.Image:
    img = new(T, T)
    rect(img, 0, 0, T - 1, T - 1, C("wood", 2))
    rng = random.Random(9)
    for _ in range(6):
        x, y = rng.randrange(T), rng.randrange(T)
        rect(img, x, y, min(T - 1, x + 3), y, C("wood", 1))
    if side == "left":
        rect(img, T - 4, 0, T - 2, T - 1, C("wood", 3))
        rect(img, T - 1, 0, T - 1, T - 1, C("timber", 0))
        rect(img, 0, 0, 0, T - 1, C("timber", 0))
    elif side == "right":
        rect(img, 1, 0, 3, T - 1, C("wood", 1))
        rect(img, 0, 0, 0, T - 1, C("timber", 0))
        rect(img, T - 1, 0, T - 1, T - 1, C("timber", 0))
    else:  # front wall seen from above: lit top, short darker face at the bottom
        rect(img, 0, 0, T - 1, 1, C("wood", 3))
        rect(img, 0, 22, T - 1, T - 1, C("timber", 1))
        rect(img, 0, 22, T - 1, 22, C("timber", 2))
    return img


def tile_atlas() -> Image.Image:
    p = [planks(i) for i in range(4)]
    tiles = p + [shadowed(p[0]), flagstone(0), flagstone(1), doormat(p[1]),
                 wall_upper(False), wall_upper(True), wall_lower(False), wall_lower(True),
                 wall_top("left"), wall_top("right"), wall_top("front"), new(T, T)]
    atlas = new(T * 8, T * 2)
    for i, t in enumerate(tiles):
        atlas.alpha_composite(t, ((i % 8) * T, (i // 8) * T))
    return atlas


# ----------------------------------------------------------------------------- furniture
def wood_top(img, x0, y0, x1, y1, seed=1):
    """A lit wooden surface seen from above: planks across, top-left highlight, warm grain."""
    rect(img, x0, y0, x1, y1, C("wood", 2))
    rng = random.Random(seed)
    for y in range(y0 + 5, y1, 6):
        rect(img, x0, y, x1, y, C("wood", 1))
    for _ in range((x1 - x0) // 6):
        gx, gy = rng.randrange(x0 + 1, x1 - 6), rng.randrange(y0 + 1, y1)
        rect(img, gx, gy, gx + rng.randrange(3, 7), gy, C("wood", 3))
    rect(img, x0, y0, x1, y0, C("wood", 3))
    rect(img, x0, y0, x0, y1, C("wood", 3))


def counter() -> Image.Image:
    """Serving counter, 4 tiles wide. Top surface 20px deep, shallow 14px front. Foot row 47."""
    w, h = 132, 52
    img = new(w, h)
    b = new(w, h)
    wood_top(b, 2, 6, w - 3, 27, seed=3)
    rect(b, 2, 27, w - 3, 28, C("wood", 0))           # top lip shadow
    rect(b, 2, 29, w - 3, 44, C("wood", 0))           # front face
    for x0 in range(5, w - 12, 25):                    # face panels
        rect(b, x0, 31, x0 + 20, 42, C("wood", 1))
        rect(b, x0 + 1, 32, x0 + 19, 32, C("wood", 2))
        rect(b, x0 + 20, 32, x0 + 20, 42, C("wood", 0))
    rect(b, 2, 45, w - 3, 46, C("timber", 0))          # kick board
    # russet runner across the top and over the front
    rect(b, 56, 6, 75, 32, C("cloth", 1))
    rect(b, 56, 6, 56, 32, C("cloth", 2))
    rect(b, 75, 6, 75, 32, C("cloth", 0))
    for x in range(57, 75, 3):
        put(b, x, 33, C("cloth", 2))
    rect(b, 58, 12, 73, 12, C("brass", 1))             # woven stripe
    img.alpha_composite(outline(b))
    soft_shadow(img, 3, 48, w - 4, 51)
    return img


def table() -> Image.Image:
    """Square-ish tavern table: big top, short apron and stout legs. Foot row 47."""
    w, h = 68, 52
    img = new(w, h)
    b = new(w, h)
    wood_top(b, 3, 6, w - 4, 33, seed=7)
    rect(b, 3, 34, w - 4, 38, C("wood", 0))            # apron
    rect(b, 3, 34, w - 4, 34, C("wood", 1))
    for lx in (6, w - 11):                              # legs
        rect(b, lx, 39, lx + 4, 46, C("wood", 0))
        rect(b, lx, 39, lx, 46, C("wood", 1))
    # runner down the middle with a brass candle holder
    rect(b, 26, 6, 41, 38, C("cloth", 1))
    rect(b, 26, 6, 26, 38, C("cloth", 2))
    rect(b, 41, 6, 41, 38, C("cloth", 0))
    rect(b, 30, 17, 37, 21, C("brass", 0))
    rect(b, 31, 17, 36, 19, C("brass", 1))
    rect(b, 32, 11, 35, 17, C("cream", 2))
    rect(b, 35, 12, 35, 17, C("cream", 0))
    put(b, 33, 9, C("fire", 2))
    put(b, 33, 10, C("fire", 1))
    put(b, 34, 10, C("fire", 3))
    img.alpha_composite(outline(b))
    soft_shadow(img, 4, 48, w - 5, 51)
    return img


def chair() -> Image.Image:
    """Chair facing right (backrest on the left); mirror it for the other side. Foot row 29."""
    w, h = 24, 32
    img = new(w, h)
    b = new(w, h)
    rect(b, 4, 2, 7, 24, C("wood", 1))     # backrest rails seen from above
    rect(b, 4, 2, 4, 24, C("wood", 2))
    rect(b, 4, 2, 7, 3, C("wood", 3))
    rect(b, 5, 8, 6, 18, C("wood", 0))
    rect(b, 8, 12, 20, 22, C("wood", 2))   # seat
    rect(b, 9, 13, 19, 20, C("cloth", 1))  # cushion
    rect(b, 9, 13, 19, 13, C("cloth", 2))
    rect(b, 19, 14, 19, 20, C("cloth", 0))
    rect(b, 8, 23, 20, 24, C("wood", 0))   # seat front
    for lx in (5, 18):                     # legs
        rect(b, lx, 25, lx + 1, 29, C("wood", 0))
    img.alpha_composite(outline(b))
    soft_shadow(img, 4, 30, 21, 31)
    return img


def stove() -> Image.Image:
    """Cast-iron cooking stove with stovepipe to the wall. 56x92, foot row 87.
    The copper pot and the fire are separate sprites (bob / animation)."""
    w, h = 56, 92
    img = new(w, h)
    b = new(w, h)
    rect(b, 24, 0, 31, 44, C("iron", 1))                # stovepipe
    rect(b, 24, 0, 25, 44, C("iron", 2))
    for y in (10, 26):
        rect(b, 23, y, 32, y + 2, C("iron", 2))         # pipe collars
        rect(b, 23, y, 32, y, C("iron", 3))
    rect(b, 6, 46, w - 7, 63, C("iron", 2))             # stove top surface
    rect(b, 6, 46, w - 7, 46, C("iron", 3))
    rect(b, 6, 46, 6, 63, C("iron", 3))
    for cx in (17, 38):                                  # hot plates
        rect(b, cx - 6, 50, cx + 6, 59, C("iron", 1))
        rect(b, cx - 5, 51, cx + 5, 58, C("iron", 0))
        rect(b, cx - 5, 51, cx + 5, 51, C("iron", 2))
    rect(b, 6, 64, w - 7, 81, C("iron", 1))             # front face
    rect(b, 6, 64, w - 7, 64, C("iron", 2))
    rect(b, 18, 68, 37, 77, C("iron", 0))               # fire window frame
    rect(b, 19, 69, 36, 76, C("fire", 0))
    rect(b, 6, 82, w - 7, 83, C("iron", 0))
    for lx in (8, w - 12):                               # feet
        rect(b, lx, 84, lx + 3, 87, C("iron", 0))
    rect(b, w - 13, 66, w - 10, 70, C("brass", 1))      # brass knob
    put(b, w - 13, 66, C("brass", 2))
    img.alpha_composite(outline(b))
    return img


def fire_frames() -> Image.Image:
    sheet = new(18 * 3, 8)
    shapes = [
        ["...2..3...2..1....", "..232.32..232.2...", ".233323312332321..", "12333333333333321.",
         "11222222222222211.", "..111111111111.....", "..................", ".................."],
        ["..2...2..3...2....", ".232.232.32..232..", "12332233332312332.", "123333333333333321",
         "112222222222222211", "..111111111111.....", "..................", ".................."],
        ["....2..2...2..2...", "...232.32.232.32..", ".1233323333233321..", "12333333333333321.",
         "11222222222222211.", "..111111111111.....", "..................", ".................."],
    ]
    key = {"1": C("fire", 0), "2": C("fire", 1), "3": C("fire", 2)}
    for f, rows in enumerate(shapes):
        for y, row in enumerate(rows):
            for x, ch in enumerate(row[:18]):
                if ch in key:
                    sheet.putpixel((f * 18 + x, y), key[ch])
        sheet.putpixel((f * 18 + 8 + f, 2), C("fire", 3))
    return sheet


def copper_pot() -> Image.Image:
    w, h = 26, 20
    img = new(w, h)
    b = new(w, h)
    for y in range(4, 17):
        half = 10 if y > 6 else 8 + (y - 4)
        for x in range(13 - half, 13 + half):
            t = (x - (13 - half)) / (2 * half)
            k = 3 if t < 0.2 else 2 if t < 0.55 else 1 if t < 0.85 else 0
            b.putpixel((x, y), C("copper", k))
    rect(b, 4, 4, 21, 6, C("copper", 3))       # rim seen from above
    rect(b, 6, 5, 19, 6, C("teal", 1))         # soup surface
    put(b, 9, 5, C("teal", 3))
    put(b, 15, 6, C("cream", 2))
    rect(b, 0, 8, 2, 10, C("copper", 1))       # handles
    rect(b, 23, 8, 25, 10, C("copper", 0))
    img.alpha_composite(outline(b))
    return img


def build() -> dict[str, Image.Image]:
    return {
        "tavern_tiles_v001.png": tile_atlas(),
        "counter_v001.png": counter(),
        "table_v001.png": table(),
        "chair_v001.png": chair(),
        "stove_v001.png": stove(),
        "stove_fire_v001.png": fire_frames(),
        "copper_pot_v001.png": copper_pot(),
    }
