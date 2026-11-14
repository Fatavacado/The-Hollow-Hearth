"""Copperfern v002 forest props: PixelLab map objects -> runtime sprites (+ derived picked states).

Pixels are drawn by PixelLab create_map_object (high top-down, single colour outline); see
source/pixellab_props/objects.json for object ids and prompts. This script draws nothing new:
  * tree_round, bush (bush_v2 re-roll), glowcap_full, moonberry_full: copied unchanged;
  * glowcap_empty: the caps are removed, leaving the grass tuft and cut stem bases (rows >= 20);
  * moonberry_empty: berry blues are recoloured onto the bush's own leaf ramp (berries picked).

Usage: python tools/art/copperfern_v002/assemble_forest_props.py
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "assets/art/benchmark/copperfern_v002/source/pixellab_props"
OUT = ROOT / "assets/art/benchmark/copperfern_v002"

GLOWCAP_CUT_ROW = 20
# moonberry leaf ramp, dark -> light (sampled from the generated bush itself)
LEAVES = [(0x0f, 0x31, 0x12), (0x1f, 0x55, 0x32), (0x34, 0x78, 0x54), (0x3c, 0x93, 0x05),
          (0x6c, 0xb1, 0x40), (0x8f, 0xcf, 0x5c)]


def lum(r: int, g: int, b: int) -> float:
    return 0.299 * r + 0.587 * g + 0.114 * b


def is_berry(r: int, g: int, b: int) -> bool:
    return b > g + 10 and b >= r


def glowcap_empty(full: Image.Image) -> Image.Image:
    out = full.copy()
    px = out.load()
    for y in range(GLOWCAP_CUT_ROW):
        for x in range(out.width):
            px[x, y] = (0, 0, 0, 0)
    return out


def moonberry_empty(full: Image.Image) -> Image.Image:
    out = full.copy()
    px = out.load()
    berries = sorted({px[x, y][:3] for y in range(out.height) for x in range(out.width)
                      if px[x, y][3] and is_berry(*px[x, y][:3])}, key=lambda c: lum(*c))
    remap = {c: LEAVES[min(len(LEAVES) - 1, i * len(LEAVES) // len(berries))] for i, c in enumerate(berries)}
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a and (r, g, b) in remap:
                px[x, y] = (*remap[(r, g, b)], 255)
    return out


def main() -> int:
    src = {n: Image.open(SRC / f"{n}.png").convert("RGBA") for n in
           ("tree_round", "bush_v2", "glowcap", "moonberry")}
    outputs = {
        "tree_round_v002.png": src["tree_round"],
        "bush_v002.png": src["bush_v2"],
        "glowcap_full_v002.png": src["glowcap"],
        "glowcap_empty_v002.png": glowcap_empty(src["glowcap"]),
        "moonberry_full_v002.png": src["moonberry"],
        "moonberry_empty_v002.png": moonberry_empty(src["moonberry"]),
    }
    for name, im in outputs.items():
        if im.getbbox() is None:
            print(f"{name} is empty")
            return 1
        if set(im.getchannel("A").getdata()) - {0, 255}:
            print(f"{name} has partial alpha")
            return 1
        im.save(OUT / name)
    print("ok:", ", ".join(outputs))
    return 0


if __name__ == "__main__":
    sys.exit(main())
