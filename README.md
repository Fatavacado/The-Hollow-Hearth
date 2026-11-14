# The Hollow Hearth

**Working title · Cozy fantasy adventure, cooking, and supernatural tavern management · Godot 4.x**

Explore a wondrous world, gather extraordinary ingredients, cook memorable meals, and welcome unusual travelers to a tavern you open whenever you choose.

**Core loop:** Explore → Gather → Cook → Open tavern → Serve → Earn → Upgrade → Explore again.

The player controls their own schedule. No compulsory daily tavern opening, rigid bedtime, or forced service shift. Cozy, colorful and magical are the default; mystery and danger provide contrast.

Start with [GAME_VISION.md](GAME_VISION.md), [GAME_DESIGN_DOCUMENT.md](GAME_DESIGN_DOCUMENT.md), and [docs/VERTICAL_SLICE.md](docs/VERTICAL_SLICE.md). Development agents must read [CLAUDE.md](CLAUDE.md).

## Status
Vertical slice **M0–M5 implemented** in Godot 4.7.2 and verified by automated tests plus agent playthroughs; see [docs/PLAYTEST_REPORT.md](docs/PLAYTEST_REPORT.md).
Still open: **owner approval of the visual benchmark** ([docs/VISUAL_BENCHMARK.md](docs/VISUAL_BENCHMARK.md)) — all art and audio are generated placeholders — and a **human playtest**.

## Play the slice
Install Godot 4.7.2-stable, then run `godot --path .` (or open `project.godot` and press F5).

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / arrow keys | left stick / d-pad |
| Interact (gather, store, cook, serve, open/close, browse) | E or Space | A |
| Stir while cooking | E or Space | A |
| Inventory | Tab or I | Y |
| Pause / close a panel | Esc | Start |

A session: walk out of the tavern into the Whisperwood, gather ingredients, store them in the pantry, cook at the hearth, flip the sign to **OPEN**, serve the lantern ghosts and velvet vampires, and buy the **Expanded Satchel** at the notice board for bigger trips. The game autosaves whenever you arrive somewhere; **Continue** on the title screen resumes.

## Developers
Setup, engine pin and commands: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) · code structure and decisions: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · asset licenses: [docs/ASSET_PROVENANCE.md](docs/ASSET_PROVENANCE.md).
Validate everything with `tools/run_tests.sh` (Git Bash, `GODOT_BIN` set to the console binary).

## Art reference for developers

Use [the approved Copperfern top-down reference](docs/ART_REFERENCE.md) and the [pixel-art production skill](.agents/skills/hollow-hearth-pixel-art/SKILL.md). The selected brighter image defines the high top-down camera, cheerful starting-region palette and visual direction; it is not an implemented game screenshot or production tileset.
