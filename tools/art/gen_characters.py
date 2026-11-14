"""Generates four-direction character sheets (player, vampire guest) and the ghost guest sheet.

Sheet layout (humanoids): 5 columns x 4 rows of 48x64 frames.
  rows    : 0 = down (front), 1 = left, 2 = right, 3 = up (back)
  columns : 0 = idle, 1..4 = walk cycle (contact, pass, contact, pass)
Foot anchor: pixel (24, 60) of every frame. In Godot: Sprite2D centered, offset (0, -28).
"""
from __future__ import annotations

from dataclasses import dataclass, field

from PIL import Image

from pixelkit import C, ROOT, new, outline, preview, put, rect, save

FW, FH = 48, 64
CX = 24  # x of the frame centre line (pixels 23|24)
FOOT_Y = 60


@dataclass
class Style:
    hair: tuple[str, str, str] = ("f0", "f1", "f2")          # shadow, base, highlight
    skin: tuple[str, str] = ("k2", "k3")                       # shadow, base
    eye: str = "m0"
    shirt: tuple[str, str] = ("t0", "t1")
    apron: tuple[str, str] | None = ("c2", "c3")
    scarf: tuple[str, str] | None = ("f3", "f4")
    pants: tuple[str, str] = ("w1", "w2")
    boots: tuple[str, str] = ("w0", "w1")
    satchel: bool = True
    cape: tuple[str, str, str] | None = None                   # shadow, base, lining
    collar: tuple[str, str] | None = None
    ponytail: bool = True
    torso_extra: int = 0                                       # taller torso
    leg_extra: int = 0
    blush: str | None = "r4"
    mouth: str = "k1"
    fang: bool = False


PLAYER = Style()
VAMPIRE = Style(
    hair=("s0", "m0", "m1"), skin=("m4", "c4"), eye="r2",
    shirt=("r0", "r1"), apron=None, scarf=None, pants=("s0", "s1"), boots=("outline", "s0"),
    satchel=False, cape=("m0", "m1", "r2"), collar=("m0", "m1"), ponytail=False,
    torso_extra=2, leg_extra=1, blush=None, mouth="r1", fang=True,
)


def col(name: str):
    return C(name)


def head_rows():
    """Silhouette spans for an 18-wide, 18-tall head (relative x range per row)."""
    return [(4, 13), (2, 15), (1, 16)] + [(0, 17)] * 12 + [(1, 16), (2, 15), (4, 13)]


def draw_head(img, st: Style, direction: str, top: int):
    x0 = CX - 9
    sh, sk = col(st.skin[0]), col(st.skin[1])
    hs, hb, hh = (col(c) for c in st.hair)
    rows = head_rows()
    for r, (a, b) in enumerate(rows):
        for rx in range(a, b + 1):
            x, y = x0 + rx, top + r
            if direction == "up":
                c = hb
            elif direction == "down":
                fringe = r == 8 and rx not in (5, 6, 11, 12)
                side_lock = r >= 8 and (rx <= 1 or rx >= 16) and r <= 14
                c = hb if (r < 8 or fringe or side_lock) else sk
                if c == sk and (rx >= 15 or r >= 16):
                    c = sh
            else:  # side view, facing left: face on the left half
                fringe = r == 8 and rx not in (3, 4, 7)
                back_hair = rx >= 9 and r <= 15
                c = hb if (r < 8 or fringe or back_hair) else sk
                if c == sk and r >= 16:
                    c = sh
            put(img, x, y, c)
    # hair light & shadow
    for r, (a, b) in enumerate(rows[:16]):
        for rx in range(a, b + 1):
            x, y = x0 + rx, top + r
            if img.getpixel((x, y)) != hb:
                continue
            if 1 <= r <= 4 and a + 2 <= rx <= a + 5 and (rx + r) % 3 != 0:
                put(img, x, y, hh)
            elif rx >= b - 1 or (r >= 12 and direction != "up") or (direction == "up" and r >= 13):
                put(img, x, y, hs)
    if direction == "up" and st.ponytail:
        rect(img, CX - 2, top + 15, CX + 1, top + 19, hb)
        rect(img, CX + 1, top + 16, CX + 1, top + 19, hs)
        rect(img, CX - 2, top + 15, CX + 1, top + 15, col("f3") if st.hair[1] == "f1" else hh)
    if direction == "down":
        _eyes(img, st, [(x0 + 5, top + 11), (x0 + 11, top + 11)])
        if st.blush:
            put(img, x0 + 3, top + 14, col(st.blush))
            put(img, x0 + 14, top + 14, col(st.blush))
        put(img, x0 + 8, top + 15, col(st.mouth))
        put(img, x0 + 9, top + 15, col(st.mouth))
        if st.fang:
            put(img, x0 + 9, top + 16, col("c4"))
    elif direction == "left":
        _eyes(img, st, [(x0 + 3, top + 11)])
        put(img, x0 - 1, top + 13, sk)      # nose tip
        if st.blush:
            put(img, x0 + 4, top + 14, col(st.blush))
        put(img, x0 + 1, top + 15, col(st.mouth))
        put(img, x0 + 10, top + 12, sh)     # ear
        put(img, x0 + 10, top + 13, sh)


def _eyes(img, st: Style, positions):
    dark = col(st.eye)
    for ex, ey in positions:
        put(img, ex, ey, dark)
        put(img, ex + 1, ey, dark)
        put(img, ex, ey + 1, col("c4"))
        put(img, ex + 1, ey + 1, dark)
        put(img, ex, ey + 2, dark)
        put(img, ex + 1, ey + 2, dark)


def draw_legs(img, st: Style, direction: str, frame: int, hip: int):
    ps, pb = (col(c) for c in st.pants)
    bs, bb = (col(c) for c in st.boots)
    leg_len = 9 + st.leg_extra
    lift = {0: (0, 0), 1: (0, 2), 2: (0, 0), 3: (2, 0), 4: (0, 0)}[frame]
    if direction in ("down", "up"):
        legs = [(CX - 6, lift[0]), (CX + 1, lift[1])]
        for lx, up in legs:
            bottom = FOOT_Y - up
            rect(img, lx, hip, lx + 4, bottom - 5, pb)
            rect(img, lx + 4, hip, lx + 4, bottom - 5, ps)
            rect(img, lx, bottom - 4, lx + 4, bottom, bb)
            rect(img, lx, bottom - 4, lx + 4, bottom - 4, bs)
    else:
        # side view (facing left): legs swing along x
        swing = {0: 0, 1: 3, 2: 0, 3: -3, 4: 0}[frame]
        for i, dx in enumerate((swing, -swing)):
            lx = CX - 3 + dx
            shade = i == 1
            rect(img, lx, hip, lx + 5, FOOT_Y - 5, ps if shade else pb)
            rect(img, lx - 1, FOOT_Y - 4, lx + 5, FOOT_Y, bs if shade else bb)
    return leg_len


def draw_torso(img, st: Style, direction: str, top: int, bottom: int):
    ts, tb = (col(c) for c in st.shirt)
    if direction in ("down", "up"):
        x0, x1 = CX - 7, CX + 6
    else:
        x0, x1 = CX - 5, CX + 4
    if st.cape and direction != "up":
        cs, cb, cl = (col(c) for c in st.cape)
        if direction == "down":
            rect(img, x0 - 3, top + 1, x0 - 1, bottom + 4, cb)
            rect(img, x1 + 1, top + 1, x1 + 3, bottom + 4, cs)
            rect(img, x0 - 1, top + 2, x0 - 1, bottom + 3, cl)
            rect(img, x1 + 1, top + 2, x1 + 1, bottom + 3, cl)
        else:
            rect(img, x1 - 1, top + 1, x1 + 4, bottom + 5, cb)
            rect(img, x1 + 3, top + 3, x1 + 4, bottom + 5, cs)
    rect(img, x0, top, x1, bottom, tb)
    rect(img, x1 - 1, top, x1, bottom, ts)
    if direction == "down":
        if st.apron:
            ab_s, ab = (col(c) for c in st.apron)
            rect(img, x0 + 2, top + 4, x1 - 2, bottom + 3, ab)
            rect(img, x1 - 3, top + 4, x1 - 2, bottom + 3, ab_s)
            put(img, x0 + 2, top + 3, ab)
            put(img, x1 - 2, top + 3, ab)
            rect(img, x0 + 4, top + 8, x1 - 4, top + 8, ab_s)  # pocket seam
        if st.satchel:
            strap = col("w2")
            for i in range(9):
                put(img, x1 - 1 - i, top + 1 + i, strap)
        if st.scarf:
            ss, sb = (col(c) for c in st.scarf)
            rect(img, CX - 4, top, CX + 3, top + 1, sb)
            rect(img, CX - 1, top + 2, CX, top + 3, ss)
        if st.collar:
            cs, cb = (col(c) for c in st.collar)
            rect(img, x0 - 1, top - 2, x0 + 2, top + 1, cb)
            rect(img, x1 - 2, top - 2, x1 + 1, top + 1, cs)
            rect(img, CX - 1, top, CX, top + 3, col("c4"))  # cravat
    elif direction == "up":
        if st.cape:
            cs, cb, _ = (col(c) for c in st.cape)
            rect(img, x0 - 2, top, x1 + 2, bottom + 6, cb)
            rect(img, x1, top, x1 + 2, bottom + 6, cs)
            if st.collar:
                rect(img, x0 - 1, top - 3, x1 + 1, top, col(st.collar[1]))
        else:
            if st.apron:
                ab_s, ab = (col(c) for c in st.apron)
                for i in range(6):
                    put(img, x0 + 2 + i, top + 1 + i, ab_s)
                    put(img, x1 - 2 - i, top + 1 + i, ab_s)
                rect(img, CX - 3, bottom - 3, CX + 2, bottom - 2, ab)  # apron bow
                put(img, CX - 1, bottom - 1, ab)
                put(img, CX, bottom - 1, ab)
            if st.scarf:
                rect(img, CX - 4, top, CX + 3, top + 1, col(st.scarf[1]))
    else:  # left
        if st.apron:
            ab_s, ab = (col(c) for c in st.apron)
            rect(img, x0 - 1, top + 3, x0 + 1, bottom + 3, ab)
        if st.scarf:
            rect(img, x0, top, x1 - 2, top + 1, col(st.scarf[1]))
            put(img, x0 - 1, top + 2, col(st.scarf[0]))
        if st.collar:
            rect(img, x0 + 2, top - 3, x1, top, col(st.collar[1]))
        if st.satchel:
            rect(img, x1 - 1, top + 6, x1 + 2, top + 10, col("w4"))
            rect(img, x1 - 1, top + 10, x1 + 2, top + 10, col("w3"))
            rect(img, x1 - 1, top + 6, x1 + 2, top + 6, col("w5"))
    if st.satchel and direction == "down":
        rect(img, x0 - 3, bottom - 4, x0, bottom, col("w4"))
        rect(img, x0 - 3, bottom - 4, x0, bottom - 4, col("w5"))
        rect(img, x0 - 3, bottom, x0, bottom, col("w3"))


def draw_arms(img, st: Style, direction: str, frame: int, shoulder: int):
    ts, tb = (col(c) for c in st.shirt)
    sh, sk = (col(c) for c in st.skin)
    swing = {0: 0, 1: 1, 2: 0, 3: -1, 4: 0}[frame]
    length = 9
    if direction in ("down", "up"):
        for ax, dy, shade in ((CX - 10, swing, False), (CX + 7, -swing, True)):
            top = shoulder + 1 + dy
            rect(img, ax, top, ax + 2, top + length - 3, ts if shade else tb)
            rect(img, ax, top + length - 2, ax + 2, top + length, sh if shade else sk)
    else:
        dx = {0: 0, 1: -2, 2: 0, 3: 2, 4: 0}[frame]
        ax = CX - 2 + dx
        top = shoulder + 1
        rect(img, ax, top, ax + 2, top + length - 3, ts)
        rect(img, ax, top + length - 2, ax + 2, top + length, sk)


def draw_humanoid(st: Style, direction: str, frame: int) -> Image.Image:
    img = new(FW, FH)
    flip = direction == "right"
    view = "left" if flip else direction
    bob = 1 if frame in (2, 4) else 0
    hip = FOOT_Y - 13 - st.leg_extra
    torso_bottom = hip - 1 + 2
    torso_top = torso_bottom - 12 - st.torso_extra
    head_top = torso_top - 18
    draw_legs(img, st, view, frame, hip)
    body = new(FW, FH)
    if view == "up":
        draw_arms(body, st, view, frame, torso_top)
        draw_torso(body, st, view, torso_top, torso_bottom)
        draw_head(body, st, view, head_top)
    else:
        draw_torso(body, st, view, torso_top, torso_bottom)
        draw_head(body, st, view, head_top)
        draw_arms(body, st, view, frame, torso_top)
    img.alpha_composite(body, (0, -bob))
    img = outline(img)
    if flip:
        img = img.transpose(Image.FLIP_LEFT_RIGHT)
    return img


def humanoid_sheet(st: Style) -> Image.Image:
    sheet = new(FW * 5, FH * 4)
    for row, direction in enumerate(("down", "left", "right", "up")):
        for frame in range(5):
            sheet.alpha_composite(draw_humanoid(st, direction, frame), (frame * FW, row * FH))
    return sheet


# ---------------------------------------------------------------- ghost
def ghost_frame(frame: int) -> Image.Image:
    """Friendly lantern ghost: floating bell shape with wavy tails. 2 frames (tail wiggle)."""
    img = new(FW, FH)
    base, mid, shade, deep = col("c4"), col("b5"), col("b4"), col("b3")
    top, bottom, radius = 22, 50, 13
    for y in range(top, bottom + 1):
        dy = y - top
        half = int(round((radius ** 2 - (radius - dy) ** 2) ** 0.5)) if dy < radius else radius
        for x in range(CX - half, CX + half):
            put(img, x, y, base)
    # wavy tails
    phase = frame % 2
    for i, tx in enumerate(range(CX - 13, CX + 9, 6)):
        drop = 3 if (i + phase) % 2 == 0 else 1
        rect(img, tx + 1, bottom + 1, tx + 4, bottom + drop, base)
    # shading: right side and bottom
    for y in range(top, bottom + 4):
        for x in range(CX - 14, CX + 14):
            if img.getpixel((x, y))[3] == 0:
                continue
            right = x >= CX + 7
            low = y >= bottom - 2
            if right and low:
                put(img, x, y, deep)
            elif right or low:
                put(img, x, y, shade)
            elif x >= CX + 3 or y >= bottom - 6:
                put(img, x, y, mid)
    # face
    for ex in (CX - 6, CX + 3):
        rect(img, ex, 32, ex + 2, 35, col("m0"))
        put(img, ex, 32, col("m2"))
        put(img, ex + 1, 33, col("c4"))
    put(img, CX - 9, 37, col("r4"))
    put(img, CX + 7, 37, col("r4"))
    rect(img, CX - 1, 38, CX, 38, col("m1"))
    # tiny lantern held at the side
    rect(img, CX + 12, 36, CX + 15, 40, col("f4"))
    rect(img, CX + 12, 36, CX + 15, 36, col("w2"))
    put(img, CX + 13, 38, col("f5"))
    return outline(img, col("m1"))


def ghost_sheet() -> Image.Image:
    sheet = new(FW * 2, FH)
    for frame in range(2):
        sheet.alpha_composite(ghost_frame(frame), (frame * FW, 0))
    return sheet


def main() -> None:
    sheets = {
        "characters/player.png": humanoid_sheet(PLAYER),
        "characters/vampire.png": humanoid_sheet(VAMPIRE),
        "characters/ghost.png": ghost_sheet(),
    }
    scratch = ROOT / ".godot" / "art_previews"
    scratch.mkdir(parents=True, exist_ok=True)
    for rel, img in sheets.items():
        save(img, rel)
        preview(img, scratch / rel.replace("/", "_"), scale=4)
        print("wrote", rel, img.size)


if __name__ == "__main__":
    main()
