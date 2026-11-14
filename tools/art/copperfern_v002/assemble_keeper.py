"""Copperfern v002 keeper: PixelLab frames -> cleaned 48x64 cells -> LibreSprite .ase + runtime sheet.

Pixels are drawn by PixelLab (character 1a08e4b3-..., v3, high top-down, 52 px; template animations
walking-6-frames and breathing-idle). This script does NOT draw anything; it only:
  1. fixes the generator defects found in review (listed in FIXES),
  2. places each 52x52 frame in a 48x64 cell with the feet on the anchor row (y = 58),
  3. hands the frame sequence to LibreSprite, which writes the editable .ase source and exports
     the runtime sheet (rows = south, west, east, north; columns = idle0-3, walk0-5).

Usage: python tools/art/copperfern_v002/assemble_keeper.py [--libresprite PATH]
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "assets/art/benchmark/copperfern_v002/source/pixellab_keeper/animations"
OUT = ROOT / "assets/art/benchmark/copperfern_v002"
LIBRESPRITE = "C:/Users/Brian/Tools/LibreSprite/libresprite.exe"

DIRS = ["south", "west", "east", "north"]
IDLE, WALK = 4, 6
CELL_W, CELL_H, FOOT_Y = 48, 64, 58
SHADOW = (129, 129, 129)          # PixelLab ground shadow, present on north walk only
BELT_GLITCH = (189, 217, 29)      # lime artefact on the north walk belt
BELT = (96, 51, 44)

# idle frame index sequence per direction; south frame 2 was drawn facing away (back of head)
IDLE_ORDER = {"south": [0, 1, 0, 3], "west": [0, 1, 2, 3], "east": [0, 1, 2, 3], "north": [0, 1, 2, 3]}


def load(anim: str, d: str, i: int) -> Image.Image:
    return Image.open(SRC / anim / d / f"frame_{i:03d}.png").convert("RGBA")


def clean(im: Image.Image) -> Image.Image:
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a and (r, g, b) == SHADOW:
                px[x, y] = (0, 0, 0, 0)
            elif a and (r, g, b) == BELT_GLITCH:
                px[x, y] = (*BELT, 255)
            elif a not in (0, 255):
                px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return im


def frames_for(d: str) -> list[Image.Image]:
    idle = [clean(load("breathing-idle", d, i)) for i in IDLE_ORDER[d]]
    walk = [clean(load("walking-6-frames", d, i)) for i in range(WALK)]
    return idle + walk


def place(frames: list[Image.Image]) -> list[Image.Image]:
    """One translation per direction (keeps the walk bob): lowest foot of any frame -> FOOT_Y."""
    boxes = [f.getbbox() for f in frames]
    bottom = max(b[3] for b in boxes) - 1
    left, right = min(b[0] for b in boxes), max(b[2] for b in boxes)
    dx = (CELL_W - (left + right)) // 2
    dy = FOOT_Y - bottom
    cells = []
    for f in frames:
        c = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
        c.alpha_composite(f, (dx, dy)) if dx >= 0 and dy >= 0 else c.paste(f, (dx, dy), f)
        cells.append(c)
    return cells


def validate(cells_by_dir: dict) -> list[str]:
    errors = []
    for d, cells in cells_by_dir.items():
        bottoms = []
        for i, c in enumerate(cells):
            box = c.getbbox()
            if box is None:
                errors.append(f"{d}[{i}] empty")
                continue
            if box[0] == 0 or box[2] == CELL_W or box[1] == 0:
                errors.append(f"{d}[{i}] touches the cell edge {box}")
            if set(c.getchannel("A").getdata()) - {0, 255}:
                errors.append(f"{d}[{i}] has partial alpha")
            bottoms.append(box[3] - 1)
        if max(bottoms) != FOOT_Y:
            errors.append(f"{d}: lowest foot at {max(bottoms)}, expected {FOOT_Y}")
    return errors


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--libresprite", default=LIBRESPRITE)
    args = ap.parse_args()

    cells_by_dir = {d: place(frames_for(d)) for d in DIRS}
    errors = validate(cells_by_dir)
    if errors:
        print("VALIDATION FAILED:\n  " + "\n  ".join(errors))
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        seq = Path(tmp)
        n = 0
        for d in DIRS:
            for c in cells_by_dir[d]:
                c.save(seq / f"keeper_{n:03d}.png")
                n += 1
        ase = OUT / "source/player_keeper_v002.ase"
        sheet = OUT / "player_runtime_v002.png"
        data = OUT / "source/player_runtime_v002_libresprite.json"
        # 1) LibreSprite loads the numbered sequence as one 40-frame sprite and saves the .ase source
        run([args.libresprite, "-b", str(seq / "keeper_000.png"), "--save-as", str(ase)])
        # 2) LibreSprite exports the runtime sheet from the .ase (10 columns x 4 rows)
        run([args.libresprite, "-b", str(ase), "--sheet-type", "rows",
             "--sheet-width", str(CELL_W * (IDLE + WALK)), "--sheet", str(sheet),
             "--data", str(data), "--format", "json-array"])

    got = Image.open(sheet)
    want = (CELL_W * (IDLE + WALK), CELL_H * len(DIRS))
    if got.size != want:
        print(f"sheet size {got.size} != {want}")
        return 1
    # the exported sheet must match the validated cells exactly
    got = got.convert("RGBA")
    for r, d in enumerate(DIRS):
        for c, cell in enumerate(cells_by_dir[d]):
            crop = got.crop((c * CELL_W, r * CELL_H, (c + 1) * CELL_W, (r + 1) * CELL_H))
            if list(crop.getdata()) != list(cell.getdata()):
                print(f"exported cell {d}[{c}] differs from the validated frame")
                return 1
    meta = {
        "asset": "player_runtime_v002.png", "cell": [CELL_W, CELL_H], "anchor": [CELL_W // 2, FOOT_Y],
        "rows": DIRS, "columns": [f"idle{i}" for i in range(IDLE)] + [f"walk{i}" for i in range(WALK)],
        "idle_fps": 4, "walk_fps": 10,
        "source": "PixelLab v3 character 1a08e4b3-7774-418c-ad16-55fdf5f62580 (templates walking-6-frames, breathing-idle)",
        "editable_source": "source/player_keeper_v002.ase (LibreSprite 1.3)",
        "fixes": ["removed north-walk ground shadow", "recoloured north-walk lime belt artefact",
                  "south idle frame 2 (facing away) replaced by frame 0"],
    }
    (OUT / "player_runtime_v002.json").write_text(json.dumps(meta, indent=2) + "\n")
    print(f"ok: {sheet.relative_to(ROOT)} {want[0]}x{want[1]}, .ase source written")
    return 0


def run(cmd: list[str]) -> None:
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(res.stdout, res.stderr)
        raise SystemExit(f"command failed: {cmd[0]} (exit {res.returncode})")


if __name__ == "__main__":
    sys.exit(main())
