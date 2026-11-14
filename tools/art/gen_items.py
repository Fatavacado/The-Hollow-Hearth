"""Item icons (16x16) and gather-node world sprites (full / picked) for the slice ingredients.

Icons:  assets/art/items/<id>.png      (ingredients, dishes, coin, satchel)
Nodes:  assets/art/nodes/<id>_full.png and <id>_empty.png
"""
from __future__ import annotations

import math
import random

from PIL import Image

from gen_world import blob, soft_shadow, speckle
from pixelkit import C, ROOT, ellipse, new, outline, preview, put, rect, save, shade_by_light


# ------------------------------------------------------------------ icons (16x16)
def icon_glowcap() -> Image.Image:
    img = new(16, 16)
    rect(img, 6, 9, 9, 14, C("c3"))
    rect(img, 8, 9, 9, 14, C("c2"))
    cap = blob(16, 16, [(8, 8, 6.5)])
    for y in range(9, 16):
        for x in range(16):
            cap.putpixel((x, y), (0, 0, 0, 0))
    shade_by_light(cap, ["t0", "t1", "t2", "t3"])
    img.alpha_composite(cap)
    for x, y in ((5, 5), (9, 4), (11, 7)):
        put(img, x, y, C("c4"))
    return outline(img)


def icon_moonberry() -> Image.Image:
    img = new(16, 16)
    rect(img, 9, 2, 12, 3, C("g4"))
    put(img, 8, 4, C("g3"))
    for cx, cy in ((4.5, 8.5), (11.5, 8.5), (8, 12.5)):
        b = blob(16, 16, [(cx, cy, 2.8)])
        shade_by_light(b, ["m1", "b2", "b3", "b4"])
        img.alpha_composite(b)
        put(img, int(cx) - 1, int(cy) - 1, C("b5"))
    return outline(img)


def icon_fernleaf() -> Image.Image:
    img = new(16, 16)
    for i in range(12):
        x, y = 3 + i, 13 - i
        put(img, x, y, C("g2"))
        if i % 2 == 0 and i < 11:
            for k in range(1, 4 - i // 5):
                put(img, x - k, y - k + 1, C("g4"))
                put(img, x + k, y + k - 1, C("g3"))
            put(img, x - 1, y - 1, C("g5"))
    return outline(img)


def icon_sweetroot() -> Image.Image:
    img = new(16, 16)
    for k, (x, y) in enumerate(((7, 1), (9, 1), (8, 2), (6, 3), (10, 2))):
        put(img, x, y, C("g4" if k % 2 else "g3"))
        put(img, x, y + 1, C("g3"))
    root = new(16, 16)
    for y in range(4, 15):
        half = max(0, int(3.5 - (y - 4) * 0.33))
        for x in range(8 - half, 9 + half):
            root.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(root, ["f1", "f2", "f3", "f4"])
    for y in (7, 10):
        put(root, 7, y, C("f1"))
    img.alpha_composite(root)
    return outline(img)


def icon_honeycomb() -> Image.Image:
    img = new(16, 16)
    comb = new(16, 16)
    for y in range(2, 14):
        inset = abs(y - 7.5) * 0.5
        for x in range(int(2 + inset), int(14 - inset)):
            comb.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(comb, ["f1", "f2", "f3", "f4"])
    img.alpha_composite(comb)
    for cx, cy in ((5, 5), (9, 5), (7, 8), (11, 8), (5, 11), (9, 11)):
        put(img, cx, cy, C("f1"))
        put(img, cx + 1, cy, C("f2"))
    put(img, 4, 3, C("f5"))
    return outline(img)


def _bowl(soup: tuple[str, str, str]) -> Image.Image:
    img = new(16, 16)
    rect(img, 2, 7, 13, 8, C(soup[1]))
    rect(img, 3, 6, 12, 6, C(soup[2]))
    bowl = new(16, 16)
    for y in range(8, 14):
        half = int(6 - (y - 8) * 0.8)
        for x in range(8 - half - 1, 8 + half + 1):
            bowl.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(bowl, ["w2", "w3", "w4", "w5"])
    img.alpha_composite(bowl)
    put(img, 6, 3, C("c3"))
    put(img, 9, 2, C("c3"))
    return outline(img)


def icon_glowcap_soup() -> Image.Image:
    img = _bowl(("t0", "t1", "t2"))
    put(img, 6, 6, C("c4"))
    put(img, 10, 7, C("g4"))
    return img


def icon_hearthroot_stew() -> Image.Image:
    img = _bowl(("f0", "f2", "f3"))
    put(img, 5, 6, C("t2"))
    put(img, 9, 6, C("g4"))
    put(img, 11, 7, C("f4"))
    return img


def icon_moonberry_tart() -> Image.Image:
    img = new(16, 16)
    crust = new(16, 16)
    for y in range(6, 14):
        for x in range(1, 15):
            if ((x - 7.5) / 7) ** 2 + ((y - 9.5) / 4) ** 2 <= 1:
                crust.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(crust, ["w3", "w4", "w5", "w6"])
    img.alpha_composite(crust)
    for cx, cy in ((5, 8), (8, 7), (11, 8), (6, 10), (9, 10)):
        put(img, cx, cy, C("b3"))
        put(img, cx, cy - 1, C("b5"))
    put(img, 8, 11, C("m2"))
    return outline(img)


def icon_coin() -> Image.Image:
    img = new(16, 16)
    c = blob(16, 16, [(8, 8, 6.2)])
    shade_by_light(c, ["f1", "f2", "f3", "f4", "f5"])
    img.alpha_composite(c)
    rect(img, 7, 5, 8, 10, C("f2"))
    put(img, 6, 4, C("f5"))
    return outline(img)


def icon_satchel() -> Image.Image:
    img = new(16, 16)
    for i in range(6):
        put(img, 4 + i, 1 + (i // 3), C("w2"))
        put(img, 11 - i, 1 + (i // 3), C("w2"))
    bag = new(16, 16)
    for y in range(4, 15):
        for x in range(2, 14):
            if not ((y > 12 and (x < 3 or x > 12))):
                bag.putpixel((x, y), (255, 255, 255, 255))
    shade_by_light(bag, ["w2", "w3", "w4", "w5"])
    img.alpha_composite(bag)
    rect(img, 2, 4, 13, 7, C("w5"))
    rect(img, 7, 6, 8, 8, C("f4"))
    return outline(img)


# ------------------------------------------------------------------ gather nodes (world sprites)
def glowcap_node(full: bool) -> Image.Image:
    img = new(32, 28)
    soft_shadow(img, 16, 25, 12, 3)
    spots = [(9, 24, 5), (19, 25, 6), (25, 23, 4)]
    if not full:
        for x, y, r in spots:
            rect(img, x - 1, y - 2, x + 1, y, C("c2"))
            put(img, x - 1, y - 2, C("c3"))
        return outline(img)
    for x, y, r in spots:
        stem = new(32, 28)
        rect(stem, x - 1, y - r - 1, x + 1, y, C("c3"))
        rect(stem, x + 1, y - r - 1, x + 1, y, C("c2"))
        img.alpha_composite(outline(stem))
        cap = new(32, 28)
        cy = y - r - 1
        for yy in range(cy - r, cy + 1):
            for xx in range(x - r - 1, x + r + 2):
                if ((xx + 0.5 - x - 0.5) / (r + 1)) ** 2 + ((yy + 0.5 - cy) / r) ** 2 <= 1:
                    cap.putpixel((xx, yy), (255, 255, 255, 255))
        shade_by_light(cap, ["t0", "t1", "t2", "t3"])
        put(cap, x - 1, cy - r + 1, C("c4"))
        put(cap, x + 2, cy - 2, C("c4"))
        img.alpha_composite(outline(cap, C("t0")))
    return img


def moonberry_node(full: bool) -> Image.Image:
    img = new(32, 30)
    soft_shadow(img, 16, 26, 13, 3)
    b = blob(32, 30, [(16, 15, 10), (8, 19, 7), (24, 19, 7), (16, 21, 8)])
    shade_by_light(b, ["g1", "g2", "g3", "g4", "g5"])
    speckle(b, 9, "g5", "g1", 0.05)
    img.alpha_composite(outline(b))
    if full:
        rng = random.Random(4)
        for _ in range(9):
            x, y = rng.randrange(7, 25), rng.randrange(8, 22)
            if img.getpixel((x, y))[3] and img.getpixel((x + 1, y + 1))[3]:
                rect(img, x, y, x + 1, y + 1, C("b3"))
                put(img, x, y, C("b5"))
                put(img, x + 1, y + 1, C("m1"))
    return img


def fern_node(full: bool) -> Image.Image:
    img = new(32, 30)
    soft_shadow(img, 16, 27, 11, 3)
    if not full:
        for x in (12, 15, 18, 21):
            rect(img, x, 24, x, 27, C("g2"))
            put(img, x, 24, C("g3"))
        return outline(img)
    fern = new(32, 30)
    for angle in (-2.4, -2.0, -1.57, -1.15, -0.75):
        for t in range(0, 17):
            x = 16 + math.cos(angle) * t * 0.9
            y = 27 + math.sin(angle) * t * 1.35 + (t * t) * 0.03
            put(fern, int(x), int(y), C("g2"))
            if t > 3 and t % 2 == 0:
                put(fern, int(x - math.sin(angle) * 2), int(y + math.cos(angle) * 2), C("g4"))
                put(fern, int(x + math.sin(angle) * 2), int(y - math.cos(angle) * 2), C("g3"))
    speckle(fern, 2, "g5", "g2", 0.08)
    img.alpha_composite(outline(fern))
    return img


def sweetroot_node(full: bool) -> Image.Image:
    img = new(28, 24)
    soft_shadow(img, 14, 21, 10, 3)
    mound = new(28, 24)
    ellipse(mound, 14, 20, 9, 3, C("d1"))
    ellipse(mound, 13, 19.5, 6, 1.6, C("d2"))
    img.alpha_composite(outline(mound))
    if full:
        crown = new(28, 24)
        rect(crown, 12, 16, 15, 19, C("f3"))
        rect(crown, 12, 16, 12, 19, C("f4"))
        img.alpha_composite(outline(crown))
        leaves = new(28, 24)
        for dx, h in ((-5, 9), (-2, 12), (1, 13), (4, 10), (7, 7)):
            for k in range(h):
                put(leaves, 14 + dx + (k // 4) * (1 if dx > 0 else -1), 16 - k, C("g4" if k > h // 2 else "g3"))
        img.alpha_composite(outline(leaves))
    return img


def honey_node(full: bool) -> Image.Image:
    img = new(48, 32)
    soft_shadow(img, 24, 28, 22, 3)
    log = new(48, 32)
    rect(log, 4, 12, 41, 27, C("w2"))
    rect(log, 4, 12, 41, 14, C("w3"))
    rect(log, 4, 25, 41, 27, C("w1"))
    for x in range(8, 40, 7):
        rect(log, x, 15, x + 3, 15, C("w1"))
    ellipse(log, 41, 19.5, 5, 8, C("w4"))
    ellipse(log, 41, 19.5, 3, 5.5, C("w1"))
    img.alpha_composite(outline(log))
    if full:
        comb = new(48, 32)
        for y in range(14, 26):
            for x in range(18, 31):
                if (x + y) % 2 == 0 or y % 3 == 0:
                    comb.putpixel((x, y), C("f4"))
                else:
                    comb.putpixel((x, y), C("f3"))
        rect(comb, 22, 26, 23, 29, C("f4"))     # drip
        img.alpha_composite(outline(comb, C("f1")))
        for bx, by in ((14, 7), (33, 5), (25, 3)):
            rect(img, bx, by, bx + 2, by + 1, C("f4"))
            put(img, bx + 1, by, C("outline"))
            put(img, bx, by - 1, C("c4"))
    return img


ICONS = {
    "glowcap": icon_glowcap, "moonberry": icon_moonberry, "fernleaf": icon_fernleaf,
    "sweetroot": icon_sweetroot, "honeycomb": icon_honeycomb,
    "glowcap_soup": icon_glowcap_soup, "moonberry_tart": icon_moonberry_tart,
    "hearthroot_stew": icon_hearthroot_stew, "coin": icon_coin, "satchel": icon_satchel,
}
NODES = {
    "glowcap": glowcap_node, "moonberry": moonberry_node, "fernleaf": fern_node,
    "sweetroot": sweetroot_node, "honeycomb": honey_node,
}


def main() -> None:
    scratch = ROOT / ".godot" / "art_previews"
    scratch.mkdir(parents=True, exist_ok=True)
    sheet = new(18 * len(ICONS), 16)
    for i, (name, fn) in enumerate(ICONS.items()):
        icon = fn()
        save(icon, f"items/{name}.png")
        sheet.alpha_composite(icon, (i * 18, 0))
    preview(sheet, scratch / "items_icons.png", scale=6)
    node_sheet = new(52 * len(NODES), 72)
    for i, (name, fn) in enumerate(NODES.items()):
        for row, full in enumerate((True, False)):
            img = fn(full)
            save(img, f"nodes/{name}_{'full' if full else 'empty'}.png")
            node_sheet.alpha_composite(img, (i * 52, row * 36))
    preview(node_sheet, scratch / "gather_nodes.png", scale=4)
    print("wrote", len(ICONS), "icons and", len(NODES) * 2, "node sprites")


if __name__ == "__main__":
    main()
