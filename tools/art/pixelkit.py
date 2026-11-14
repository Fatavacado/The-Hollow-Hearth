"""Shared helpers and palette for The Hollow Hearth placeholder pixel art.

Everything produced with this kit is original work of the project (see docs/ASSET_PROVENANCE.md).
Outputs are deterministic: every generator seeds its own random.Random.
"""
from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "assets" / "art"


def hexc(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return (int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16), alpha)


# One deliberate palette shared by every asset. Ramps run dark -> light.
PALETTE = {
    "outline": "#2a1a1f",
    # foliage
    "g0": "#1d3b2c", "g1": "#285236", "g2": "#356b3f", "g3": "#4b8a46", "g4": "#6aa84f",
    "g5": "#94c95e", "g6": "#c6e383",
    # bark / wood
    "w0": "#2b1b17", "w1": "#43291f", "w2": "#5e3b2a", "w3": "#7d5236", "w4": "#a06d45",
    "w5": "#c79260", "w6": "#e3b98a",
    # dirt path
    "d0": "#5a4030", "d1": "#77583f", "d2": "#957352", "d3": "#b39167", "d4": "#cfb084",
    # stone
    "s0": "#2c2b35", "s1": "#45444f", "s2": "#62616b", "s3": "#86848c", "s4": "#aaa8ae",
    "s5": "#cfcdd0",
    # water
    "b0": "#1b2f52", "b1": "#244a7a", "b2": "#2f6aa3", "b3": "#4b93c7", "b4": "#7cc0e3",
    "b5": "#bfe8f5",
    # fire / warm light
    "f0": "#7a2a1c", "f1": "#b8462a", "f2": "#e36f2f", "f3": "#f59c3c", "f4": "#ffcc66",
    "f5": "#fff1b8",
    # magic violet / spirit teal
    "m0": "#2a2150", "m1": "#43358a", "m2": "#6a58c2", "m3": "#9a8af0", "m4": "#c9c0ff",
    "t0": "#1f5c5a", "t1": "#2f8c84", "t2": "#4fc1b0", "t3": "#94ecd9",
    # berry reds
    "r0": "#4a1631", "r1": "#7d2443", "r2": "#b13a55", "r3": "#e0607a", "r4": "#f4a0ac",
    # cream / cloth
    "c0": "#9a8460", "c1": "#c4ad84", "c2": "#e6d4ac", "c3": "#f7ecd0", "c4": "#fffaf0",
    # skin
    "k0": "#8a4f3a", "k1": "#c27e5f", "k2": "#e3a98a", "k3": "#f5cfae",
}


def C(name: str, alpha: int = 255) -> tuple[int, int, int, int]:
    return hexc(PALETTE[name], alpha)


CLEAR = (0, 0, 0, 0)


def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w, h), CLEAR)


def put(img: Image.Image, x: int, y: int, color) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def rect(img: Image.Image, x0: int, y0: int, x1: int, y1: int, color) -> None:
    """Filled rectangle, inclusive coordinates."""
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            put(img, x, y, color)


def ellipse(img: Image.Image, cx: float, cy: float, rx: float, ry: float, color) -> None:
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                put(img, x, y, color)


def opaque(img: Image.Image, x: int, y: int) -> bool:
    return 0 <= x < img.width and 0 <= y < img.height and img.getpixel((x, y))[3] > 0


def outline(img: Image.Image, color=None, diagonal: bool = False) -> Image.Image:
    """Adds a 1px outline outside the opaque silhouette."""
    color = color or C("outline")
    out = img.copy()
    offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    if diagonal:
        offsets += [(-1, -1), (1, -1), (-1, 1), (1, 1)]
    for y in range(img.height):
        for x in range(img.width):
            if img.getpixel((x, y))[3] == 0 and any(opaque(img, x + dx, y + dy) for dx, dy in offsets):
                out.putpixel((x, y), color)
    return out


def paste(dst: Image.Image, src: Image.Image, x: int, y: int) -> None:
    dst.alpha_composite(src, (x, y))


def shade_by_light(img: Image.Image, ramp: list[str], lx: float = -0.6, ly: float = -0.8) -> None:
    """Re-colors every opaque pixel along `ramp` based on a pseudo-normal from the silhouette
    (distance to edges in the light direction). Cheap volumetric shading for round props."""
    w, h = img.size
    cells = [(x, y) for y in range(h) for x in range(w) if img.getpixel((x, y))[3] > 0]
    if not cells:
        return
    for x, y in cells:
        # how far we can step toward / away from the light before leaving the shape
        toward = 0
        while opaque(img, int(x + lx * (toward + 1)), int(y + ly * (toward + 1))) and toward < 12:
            toward += 1
        away = 0
        while opaque(img, int(x - lx * (away + 1)), int(y - ly * (away + 1))) and away < 12:
            away += 1
        t = away / max(1, toward + away)  # 1 = facing light
        idx = min(len(ramp) - 1, int(t * len(ramp)))
        img.putpixel((x, y), C(ramp[idx]))


class TileNoise:
    """Value noise that tiles with the given period (in pixels)."""

    def __init__(self, seed: int, period: int, cell: int):
        self.period = period
        self.cell = cell
        self.n = period // cell
        rng = random.Random(seed)
        self.grid = [[rng.random() for _ in range(self.n)] for _ in range(self.n)]

    def at(self, x: float, y: float) -> float:
        gx, gy = x / self.cell, y / self.cell
        x0, y0 = int(math.floor(gx)), int(math.floor(gy))
        fx, fy = gx - x0, gy - y0
        sx, sy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
        n = self.n

        def g(ix, iy):
            return self.grid[iy % n][ix % n]

        top = g(x0, y0) * (1 - sx) + g(x0 + 1, y0) * sx
        bot = g(x0, y0 + 1) * (1 - sx) + g(x0 + 1, y0 + 1) * sx
        return top * (1 - sy) + bot * sy


def fractal(noises: list[TileNoise], x: float, y: float) -> float:
    total, weight, amp = 0.0, 0.0, 1.0
    for nz in noises:
        total += nz.at(x, y) * amp
        weight += amp
        amp *= 0.5
    return total / weight


def save(img: Image.Image, relpath: str) -> Path:
    path = ART / relpath
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    return path


def preview(img: Image.Image, path: Path, scale: int = 4, bg=(60, 52, 48, 255)) -> None:
    """Nearest-neighbour enlarged copy on a flat background, for visual review only."""
    base = Image.new("RGBA", img.size, bg)
    base.alpha_composite(img)
    base.resize((img.width * scale, img.height * scale), Image.NEAREST).save(path)
