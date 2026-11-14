"""Copperfern player (benchmark v002): hand-authored native pixels, four directions, 2-frame idle and
6-frame walk. Frame 48x64, feet baseline row 57 (outline row), anchor (24,58). Light: upper left.

Parts (face, torso, sleeves, trousers, boots, satchel) are drawn by hand as pixel rows below. The
short curly hair is built from hand-placed curl clusters with one shared shading rule so it reads
the same in every direction. The satchel sits on the character's LEFT hip: viewer's right facing
south, viewer's left facing north, in front facing west, mostly hidden behind the body facing east
(east is NOT a mirror of west for the satchel/strap layers).

Exports (assets/art/benchmark/copperfern/):
  player_walk_v001.png     288x256  6 cols; rows south, west, east, north
  player_idle_v001.png      96x256  2 cols; same rows
  player_runtime_v001.png  384x256  per row: idle0 idle1 walk0..walk5 (used by the Godot Player)
"""
from __future__ import annotations

import math

from PIL import Image

from cf_palette import C, blit_ascii, outline

FW, FH = 48, 64
DIRS = ("south", "west", "east", "north")

K = {
    "o": C("outline"), "e": (31, 22, 28, 255), "w": C("cream", 2), "u": C("russet", 1),
    "h": C("russet", 3),
    "1": C("hair", 0), "2": C("hair", 1), "3": C("hair", 2), "4": C("hair", 3),
    "a": C("skin", 0), "b": C("skin", 1), "c": C("skin", 2), "d": C("skin", 3),
    "T": C("teal", 0), "t": C("teal", 1), "g": C("teal", 2), "G": C("teal", 3),
    "k": C("cream", 0), "K": C("cream", 1), "W": C("cream", 2),
    "R": C("russet", 0), "r": C("russet", 1), "s": C("russet", 2), "S": C("russet", 3),
    "L": C("leather", 0), "l": C("leather", 1), "m": C("leather", 2),
    "B": C("brass", 0), "y": C("brass", 1), "Y": C("brass", 2),
    "p": C("trouser", 0), "P": C("trouser", 1), "q": C("trouser", 2),
    "n": C("boot", 0), "N": C("boot", 1), "M": C("boot", 2),
}

# ----------------------------------------------------------------------------- south (facing camera)
FACE_S = [  # x=18, y=19
    "..dddddddd..",
    ".dddddddddd.",
    "dddddddddddc",
    "dddddddddddc",
    "ddweddddwedc",
    "ddeeddddeedc",
    "dhddddddddhc",
    "dddddddddddc",
    ".ddddduudccc",
    "..cdddddccb.",
    "...cccccbb..",
    "....bbbba...",
]
TORSO_S = [  # x=16, y=31
    "....obbbbbbo....",
    "..oottKWWKttoo..",
    ".otGGgKWKggtTto.",
    "otGGggkKkgggtTTo",
    "otGgglgkggggtTTo",
    "otGggglggggggtTo",
    "otgggggllgggttTo",
    "otgggggggllgttTo",
    "otTgggggggglltTo",
    "oLLLLLLyYLLLLlLo",
    "orSSssssssssssro",
    "orSsssssssssssro",
    "orSsssssRssssrro",
    "orsssssRRsssssro",
    ".orsssRRrRsssro.",
    ".orrssRo.oRssro.",
    "..oRRRo...oRRRo.",
]
ARM_S_LIT = [  # viewer-left arm (character's right), lit side
    ".ooo.",
    "oGggo",
    "oGgto",
    "oggto",
    "ogtto",
    "oGGgo",
    "oKkko",
    "oddco",
    "odcco",
    ".ooo.",
]
ARM_S_SHADE = [  # viewer-right arm, shadow side
    ".ooo.",
    "oggto",
    "ogtto",
    "otttT",
    "otTTo",
    "oGggo",
    "okkko",
    "occbo",
    "ocbbo",
    ".ooo.",
]
SATCHEL_S = [  # character's left hip = viewer's right
    ".oooooo.",
    "ommmmllo",
    "omllllLo",
    "oyYlllLo",
    "oBylllLo",
    "olLLLLLo",
    ".oooooo.",
]

# ----------------------------------------------------------------------------- north (back to camera)
TORSO_N = [  # x=16, y=31
    "....oaaaaaao....",
    "..ottggggggtoo..",
    ".otGggggggggTto.",
    "otGGlggggggtTTto",
    "otGgllggggggtTTo",
    "otGgggllgggggtTo",
    "otggggggllggttTo",
    "otgggggggglltTTo",
    "otTggggggggglTTo",
    "oLLLLLLLLLLLLLLo",
    "orsssssRRsssssro",
    "orSsssRrrRsssrro",
    "orSssssRRssssrro",
    "orsssssRRsssssro",
    ".orsssRRrRsssro.",
    ".orrssRo.oRssro.",
    "..oRRRo...oRRRo.",
]
SATCHEL_N = [  # character's left hip = viewer's left, seen from behind
    ".oooooo.",
    "ommmllLo",
    "omllllLo",
    "omlllLLo",
    "olllLLLo",
    "oLLLLLLo",
    ".oooooo.",
]

# ----------------------------------------------------------------------------- west (facing left)
FACE_W = [  # x=15, y=19 (profile, nose at the left edge)
    "...dddddd.",
    "..ddddddd.",
    "..ddddddd.",
    "..dddddddd",
    "..weddddcc",
    "..eedddddc",
    ".dddddddcc",
    "ddhddddccc",
    ".uddddcc..",
    "..ddddcc..",
    "...ccbb...",
    "....bba...",
]
TORSO_W = [  # x=18, y=31 (13 wide; chest faces left)
    "....obbbbo...",
    "..oKKgtttto..",
    ".oKkGgggtTto.",
    ".olkGggggtto.",
    ".oGlgggggtto.",
    ".oGglggggtTo.",
    ".oGggggggtTo.",
    ".ogggggggtTo.",
    ".otgggggttTo.",
    ".oyLLLLLLLLo.",
    "osSssssssrro.",
    "osSsssssssro.",
    "orSsssssssro.",
    "orsssssssrro.",
    ".orssssssro..",
    ".orrsssssro..",
    "..oRRRRRRo...",
]
ARM_W = [  # near arm (character's left side faces camera), drawn over the torso
    ".ooo.",
    "oGggo",
    "oGgto",
    "oggto",
    "ogtto",
    "oGGgo",
    "oKkko",
    "oddco",
    "odcco",
    ".ooo.",
]
SATCHEL_W = [  # west: on the near hip, in front of the apron
    ".oooooo.",
    "ommmmllo",
    "omllllLo",
    "oyYlllLo",
    "oBylllLo",
    "olLLLLLo",
    ".oooooo.",
]
SATCHEL_E_BEHIND = [  # east: left hip is on the far side; only the satchel's back edge peeks out
    ".ooo",
    "oLlo",
    "oLlo",
    "oLLo",
    ".ooo",
]

# ----------------------------------------------------------------------------- legs and boots
LEG = ["oPPpo", "oPPpo", "oPPpo", "oPPpo", "oqPpo", "oPPpo"]  # 6 rows, trousers
BOOT_FRONT = ["oNMNo.", "oMNNNo", "oNNNNo", "onnnno", ".oooo."]  # toe to the right; mirrored for left foot
LEG_SIDE = ["oPPppo", "oPPppo", "oPPppo", "oPPpo.", "oqPpo.", "oPPpo."]
BOOT_SIDE = ["..oNMNo", ".oMNNNo", "oMNNNNo", "onnnnno", ".ooooo."]  # toe to the left (facing west)

# Walk cycle, 6 frames. Front/back views: (lift_left, lift_right). Side view: near-leg (x offset, lift);
# far leg runs half a cycle later. Contact frames 0 and 3 put both feet on the ground plane.
FRONT_LIFT = [(0, 0), (2, 0), (1, 0), (0, 0), (0, 2), (0, 1)]
SIDE_NEAR = [(-3, 0), (-1, 0), (1, 0), (3, 0), (1, 2), (-2, 1)]
ARM_SWING_FRONT = [0, 1, 1, 0, -1, -1]
BOB = [0, 1, 0, 0, 1, 0]


def _hair(img: Image.Image, curls: list[tuple[float, float, float]], light=(-0.7, -0.7)) -> None:
    """Curly hair from (cx, cy, r) curls, back to front: lit upper left, dark rim on the far side so
    neighbouring curls separate into readable clusters."""
    lx, ly = light
    for cx, cy, r in curls:
        for y in range(int(cy - r) - 1, int(cy + r) + 2):
            for x in range(int(cx - r) - 1, int(cx + r) + 2):
                dx, dy = x + 0.5 - cx, y + 0.5 - cy
                d = math.hypot(dx, dy)
                if d > r:
                    continue
                facing = -(dx * lx + dy * ly) / max(r, 0.01)
                if d > r - 0.9 and facing > -0.1:
                    shade = "1"
                elif facing < -0.5:
                    shade = "4"
                elif facing < 0.1:
                    shade = "3"
                else:
                    shade = "2"
                img.putpixel((x, y), K[shade])


CURLS = {
    "south_back": [(17.2, 21.5, 2.7), (30.8, 21.5, 2.7), (19.5, 17.2, 3.0), (24, 15.6, 3.2),
                   (28.5, 17.2, 3.0), (16.6, 24.6, 2.0), (31.4, 24.6, 2.0), (21.5, 19, 2.6),
                   (26.5, 19, 2.6)],
    "south_front": [(20.2, 20.6, 2.2), (24.2, 20.0, 2.3), (27.8, 21.0, 1.8)],
    "north": [(17.2, 21.5, 2.9), (30.8, 21.5, 2.9), (19.5, 17.2, 3.0), (24, 15.6, 3.2),
              (28.5, 17.2, 3.0), (21.2, 20.5, 2.9), (26.8, 20.5, 2.9), (17.5, 25.5, 2.5),
              (30.5, 25.5, 2.5), (21, 24.8, 2.8), (27, 24.8, 2.8), (24, 23, 3.0), (20.5, 28.2, 2.2),
              (24, 28.6, 2.3), (27.5, 28.2, 2.2)],
    "west_back": [(26.2, 17.5, 3.1), (29.2, 21.8, 3.0), (21.8, 16.0, 3.1), (28.2, 25.8, 2.4),
                  (25.0, 21.5, 2.8), (18.6, 18.6, 2.6), (25.5, 27.5, 2.0)],
    "west_front": [(17.8, 20.4, 2.0), (21.2, 19.4, 2.2)],
}


def _front_legs(img: Image.Image, phase: int) -> None:
    lift_l, lift_r = FRONT_LIFT[phase]
    for x, lift, flip in ((18, lift_l, True), (25, lift_r, False)):
        rows = LEG[: len(LEG) - lift]
        blit_ascii(img, rows, x, 47, K)
        bx = x - 1 if flip else x
        blit_ascii(img, BOOT_FRONT, bx, 53 - lift, K, flip=flip)


def _side_legs(img: Image.Image, phase: int) -> None:
    nx, nlift = SIDE_NEAR[phase]
    fx, flift = SIDE_NEAR[(phase + 3) % 6]
    shade = {"P": "p", "q": "P", "p": "p"}
    for dx, lift, far in ((fx, flift, True), (nx, nlift, False)):
        leg = LEG_SIDE[: len(LEG_SIDE) - lift]
        boot = BOOT_SIDE
        if far:
            leg = ["".join(shade.get(ch, ch) for ch in row) for row in leg]
            boot = [row.replace("M", "N").replace("N", "n") for row in boot]
        blit_ascii(img, leg, 21 + dx, 47, K)
        blit_ascii(img, boot, 20 + dx, 53 - lift, K)


def _frame(direction: str, phase: int, walking: bool, breath: int = 0) -> Image.Image:
    p = phase if walking else 0
    lower = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    upper = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    view = "west" if direction in ("west", "east") else direction
    swing = ARM_SWING_FRONT[p] if walking else 0
    if view in ("south", "north"):
        _front_legs(lower, p)
    else:
        _side_legs(lower, p)
    if view == "south":
        blit_ascii(upper, TORSO_S, 16, 31, K)
        blit_ascii(upper, ARM_S_LIT, 12, 33 + swing, K)
        blit_ascii(upper, ARM_S_SHADE, 31, 33 - swing, K)
        _hair(upper, CURLS["south_back"])
        blit_ascii(upper, FACE_S, 18, 19, K)
        _hair(upper, CURLS["south_front"])
        blit_ascii(upper, SATCHEL_S, 28, 40, K)
    elif view == "north":
        blit_ascii(upper, SATCHEL_N, 12, 40, K)
        blit_ascii(upper, TORSO_N, 16, 31, K)
        blit_ascii(upper, ARM_S_LIT, 12, 33 - swing, K)
        blit_ascii(upper, ARM_S_SHADE, 31, 33 + swing, K)
        _hair(upper, CURLS["north"])
    else:
        arm_dx = -SIDE_NEAR[p][0] if walking else 0
        if direction == "east":
            blit_ascii(upper, SATCHEL_E_BEHIND, 29, 41, K)  # becomes the back edge after the flip
        blit_ascii(upper, TORSO_W, 18, 31, K)
        _hair(upper, CURLS["west_back"])
        blit_ascii(upper, FACE_W, 15, 19, K)
        _hair(upper, CURLS["west_front"])
        if direction == "west":
            blit_ascii(upper, SATCHEL_W, 22, 40, K)
        blit_ascii(upper, ARM_W, 22 + arm_dx, 33, K)
    img = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
    img.alpha_composite(lower)
    lift = (BOB[p] if walking else 0) + breath
    img.alpha_composite(upper, (0, lift))
    img = outline(img)
    if direction == "east":
        img = img.transpose(Image.FLIP_LEFT_RIGHT)
    return img


def frames() -> dict[str, dict[str, list[Image.Image]]]:
    return {d: {"idle": [_frame(d, 0, False, 0), _frame(d, 0, False, 1)],
                "walk": [_frame(d, p, True) for p in range(6)]} for d in DIRS}
