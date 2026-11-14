"""Copperfern benchmark palette: named material ramps (dark -> light) for the brighter starting region.

Anchors from docs/ART_REGIONAL_STYLE.md (ink, spruce, teal, russet, brass, cream, moss) are kept;
ramps are extended for the approved bright daylight look. Candidate palette `copperfern_candidate_v001`.
"""
from __future__ import annotations

from PIL import Image

RAMPS = {
    # characters
    "outline": ["#2e1f1c"],
    "ink": ["#293b45"],
    "hair": ["#22140f", "#3a2218", "#55321f", "#77492c"],
    "skin": ["#6b3a25", "#965634", "#bb7a49", "#d99a62"],
    "teal": ["#22464a", "#3e6861", "#5c9d91", "#8cc6b4"],
    "cream": ["#c8a97c", "#f1dbb1", "#fff4dc"],
    "russet": ["#6c3326", "#8f4733", "#ae6549", "#cd875f"],
    "leather": ["#4f2e1f", "#71442b", "#96613c"],
    "brass": ["#9c6a2a", "#d3a158", "#f4d58e"],
    "trouser": ["#2b2a33", "#3f3d49", "#58566a"],
    "boot": ["#3a2218", "#5b3825", "#7d5434"],
    # forest
    "grass": ["#3f7a2c", "#58993a", "#75b443", "#96cc4f", "#c4e56a"],
    "path": ["#a8763f", "#c79a5c", "#dcb877", "#ecd29a", "#f7e7bf"],
    "leaf": ["#24512a", "#346f2f", "#4b8f36", "#6cb03f", "#95cf4c", "#cbe86a"],
    "bark": ["#3d2417", "#5c3722", "#80512f", "#a36d3f"],
    "berry": ["#2f3f86", "#4f6fc8", "#8fb5f2", "#e2efff"],
    "cap": ["#1f5a58", "#2e8a82", "#4fc1b0", "#a2f0dc"],
    "stem": ["#b49a7a", "#e3cfaa", "#fff1d6"],
    "flower": ["#e86a5a", "#f6c94e", "#ffffff", "#b993e6"],
    # tavern
    "wood": ["#7a4724", "#a0602f", "#c37f3f", "#dc9e56", "#efc07a"],
    "plaster": ["#d9c49c", "#ecdcb9", "#f8eed6"],
    "timber": ["#4a2b19", "#6d4126", "#8f5a33"],
    "stone": ["#7d7570", "#9b938b", "#bab2a6", "#d6cfc2"],
    "iron": ["#24262c", "#373a43", "#50545e", "#737985"],
    "copper": ["#7a3c22", "#b0603a", "#dc8a52", "#f6bd86"],
    "fire": ["#c8402a", "#f07d32", "#ffc04d", "#fff2a8"],
    "cloth": ["#8a3a2e", "#b85440", "#d97a5b"],
}


def rgb(hex_color: str, alpha: int = 255) -> tuple[int, int, int, int]:
    h = hex_color.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), alpha)


def C(ramp: str, index: int = 0, alpha: int = 255) -> tuple[int, int, int, int]:
    return rgb(RAMPS[ramp][index], alpha)


def blit_ascii(img: Image.Image, rows: list[str], x: int, y: int, key: dict[str, tuple], flip: bool = False) -> None:
    """Draws hand-authored pixel rows. '.' and ' ' are transparent; other chars map through `key`."""
    width = max(len(r) for r in rows)
    for j, row in enumerate(rows):
        row = row.ljust(width, ".")
        if flip:
            row = row[::-1]
        for i, ch in enumerate(row):
            if ch in ". ":
                continue
            if ch not in key:
                raise KeyError(f"unknown pixel key {ch!r}")
            px, py = x + i, y + j
            if 0 <= px < img.width and 0 <= py < img.height:
                img.putpixel((px, py), key[ch])


def outline(img: Image.Image, color=None) -> Image.Image:
    """1px outline around opaque pixels. Pixels already drawn in the outline colour are not outlined
    again, so hand-drawn parts that carry their own outline never get a doubled 2px edge."""
    color = color or C("outline")
    out = img.copy()
    w, h = img.size
    for yy in range(h):
        for xx in range(w):
            if img.getpixel((xx, yy))[3]:
                continue
            for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                nx, ny = xx + dx, yy + dy
                if 0 <= nx < w and 0 <= ny < h:
                    px = img.getpixel((nx, ny))
                    if px[3] == 255 and px != color:
                        out.putpixel((xx, yy), color)
                        break
    return out


def zoom(img: Image.Image, scale: int, bg=None) -> Image.Image:
    base = Image.new("RGBA", img.size, bg or (0, 0, 0, 0))
    base.alpha_composite(img)
    return base.resize((img.width * scale, img.height * scale), Image.NEAREST)
