"""Builds the Copperfern art benchmark (v001) into assets/art/benchmark/copperfern/ with metadata.

Usage (repo root):  python tools/art/copperfern/build_copperfern.py
Deterministic: the scripts in this folder are the editable source of every pixel.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

import cf_forest
import cf_player
import cf_tavern

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "assets" / "art" / "benchmark" / "copperfern"


def sheets() -> dict[str, Image.Image]:
    frames = cf_player.frames()
    walk = Image.new("RGBA", (48 * 6, 64 * 4), (0, 0, 0, 0))
    idle = Image.new("RGBA", (48 * 2, 64 * 4), (0, 0, 0, 0))
    runtime = Image.new("RGBA", (48 * 8, 64 * 4), (0, 0, 0, 0))
    for row, direction in enumerate(cf_player.DIRS):
        for col, im in enumerate(frames[direction]["walk"]):
            walk.alpha_composite(im, (col * 48, row * 64))
            runtime.alpha_composite(im, ((col + 2) * 48, row * 64))
        for col, im in enumerate(frames[direction]["idle"]):
            idle.alpha_composite(im, (col * 48, row * 64))
            runtime.alpha_composite(im, (col * 48, row * 64))
    return {"player_walk_v001.png": walk, "player_idle_v001.png": idle, "player_runtime_v001.png": runtime}


def validate_sheet(img: Image.Image, cols: int, rows: int, name: str) -> None:
    assert img.size == (48 * cols, 64 * rows), (name, img.size)
    for r in range(rows):
        for c in range(cols):
            cell = img.crop((c * 48, r * 64, (c + 1) * 48, (r + 1) * 64))
            box = cell.getchannel("A").getbbox()
            assert box, f"{name}: empty frame row {r} col {c}"
            assert box[3] == 58, f"{name}: feet not on baseline in row {r} col {c} (bottom {box[3]})"
            alphas = set(cell.getchannel("A").getdata())
            assert alphas <= {0, 255}, f"{name}: semi-transparent pixels in row {r} col {c}"


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    images = {}
    images.update(sheets())
    images.update(cf_forest.build())
    images.update(cf_tavern.build())
    validate_sheet(images["player_walk_v001.png"], 6, 4, "walk")
    validate_sheet(images["player_idle_v001.png"], 2, 4, "idle")
    meta = {"id": "copperfern_benchmark_v001", "status": "benchmark (owner review pending)",
            "palette": "copperfern_candidate_v001", "tile": [32, 32], "files": {}}
    for name, img in images.items():
        path = OUT / name
        img.save(path)
        meta["files"][name] = {"size": list(img.size),
                               "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    meta["player"] = {
        "frame_size": [48, 64], "anchor": [24, 58], "rows": list(cf_player.DIRS),
        "walk": {"file": "player_walk_v001.png", "columns": 6, "fps": 10},
        "idle": {"file": "player_idle_v001.png", "columns": 2, "fps": 2},
        "runtime": {"file": "player_runtime_v001.png", "columns": 8, "layout": "idle0 idle1 walk0..walk5"},
        "notes": "east is drawn separately for the satchel layer (left hip hidden behind the body)",
    }
    (OUT / "copperfern_benchmark_v001.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print("wrote", len(images), "images to", OUT)


if __name__ == "__main__":
    main()
