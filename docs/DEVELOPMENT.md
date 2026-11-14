# Development Setup

## Engine pin
- **Godot 4.7.2-stable, official build** (`4.7.2.stable.official.ed1daf0bf`), standard (non-.NET) edition, GDScript only.
- Windows binaries: `Godot_v4.7.2-stable_win64.exe` (editor/game) and `Godot_v4.7.2-stable_win64_console.exe` (CLI; use this for scripts so output and exit codes reach the terminal).
- Renderer: GL Compatibility (2D-only project; see decision log in [ARCHITECTURE.md](ARCHITECTURE.md)).
- `tests/unit/test_project_setup.gd` fails on any other engine version. Upgrading is a deliberate change: update this file, `config/features` in `project.godot`, and that test together.

## One-time setup
1. Install Godot 4.7.2-stable (see above). Export templates 4.7.2.stable are only needed for builds.
2. Point scripts at the console binary (Git Bash):
   `export GODOT_BIN="/c/path/to/Godot_v4.7.2-stable_win64_console.exe"`
3. Open the project in the editor once (or run the validation script) so `.godot/` is generated.

## Everyday commands (Git Bash, from repo root)
| Purpose | Command |
|---|---|
| Full validation (import → tests → headless boot) | `tools/run_tests.sh` |
| Run a subset of tests | `tools/run_tests.sh --filter=inventory` |
| Play the game | `"$GODOT_BIN" --path .` |
| Timed agent playthrough (real movement), report in `--out` | `"$GODOT_BIN" --headless --path . res://tests/playtest/full_session.tscn -- --out=/tmp/session --speed=6` |
| Same, windowed, with milestone screenshots | `"$GODOT_BIN" --path . res://tests/playtest/full_session.tscn -- --out=/tmp/session --speed=2 --shots` |
| Capture review screenshots (`benchmark`, `gathering`, `cooking`, `service`, `menus`) | `"$GODOT_BIN" --path . res://tests/visual/capture_benchmark.tscn -- --out=/tmp/shots --scenario=service` |
| Regenerate placeholder art, font and audio | `python tools/art/build_all.py && python tools/art/gen_audio.py` |

`tools/run_tests.sh` exits non-zero if any test fails **or** any engine/script error is logged during import, tests or boot (including resources leaked at exit). Logs go to `.godot/test_logs/` (git-ignored). Tests and agent runs use their own save files, never the player's `user://savegame.json`.

## Conventions
- GDScript with static types; `snake_case` files and functions, `PascalCase` `class_name`s.
- Scene scripts live next to their `.tscn`; scene-independent logic lives in `scripts/`.
- Commit the generated `*.uid` and `*.import` sidecar files; never commit `.godot/`.
- Every gameplay rule gets a headless test written first (see [ARCHITECTURE.md](ARCHITECTURE.md#testing-strategy)).
- New assets must be logged in [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md) before they are committed.
