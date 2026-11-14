# Technical Architecture — Vertical Slice

Scope: the M0–M5 slice in [VERTICAL_SLICE.md](VERTICAL_SLICE.md). Keep this document in sync with the
code; sections marked *(planned)* do not exist yet.

## Shape of the game
```
Main (scenes/main)                persistent root: swaps world scenes, owns HUD + overlays
├── WorldSlot                     one World at a time: Tavern interior or Forest
│   └── World (scenes/world)      Ground TileMapLayer + Actors (Y-sorted: player, props, guests)
├── HUD (CanvasLayer)             coins, satchel, prompts, toasts          (planned, M2)
├── BannerLayer / FadeLayer       location banner, fade-to-black travel transition
└── Overlays                      title, panels, pause                     (planned)

Autoloads
├── GameState                     mutable session state (+ signals), travel requests
└── GameDB                        read-only registry of data Resources     (planned, M2)
```

### Worlds
- `World` (`scenes/world/world.gd`) parses `data/maps/<name>.txt` (one char = one 32×32 cell) with
  `MapGrid`, lets the subclass paint terrain, then merges blocked cells into a few collision boxes
  (`CollisionRects`) and walls off the map edge. Hand-placed nodes (furniture, `DoorTrigger`s,
  `SpawnPoint`s) live in the `.tscn`.
- The forest uses a **dual grid** (`DualGrid`): display tiles sit on cell corners and pick one of 16
  transition tiles per terrain pair, so terrain edges are organic without hand-painted autotiles.
- `Prop` (`scenes/props/prop.tscn`) is the one reusable world object: texture + `foot_row` anchor +
  optional feet-level blocker + optional fade-when-behind for tall props.
- Travel: `DoorTrigger` → `GameState.request_travel(world, spawn)` → `Main` fades out, swaps the
  world, moves the player to the `SpawnPoint`, sets camera limits, fades in. Input is disabled while
  travelling.

## Layers and rules
1. **Definitions are data.** Items, recipes, guests and upgrades are `Resource` subclasses
   (`ItemData`, `RecipeData`, `GuestData`, `UpgradeData`) stored as `.tres` under `data/`. They are
   never mutated at runtime. `GameDB` exposes them by id through explicit preload lists (export-safe,
   no directory scanning).
2. **Runtime state is separate.** Everything that changes during play (coins, inventories, owned
   upgrades, gather-node timers, play time, location) lives in `GameState`, built from plain
   `RefCounted` models such as `Inventory`. Models never touch the scene tree, so they are unit-testable.
3. **Rules live in systems, not scenes.** Gathering, cooking, order selection and purchasing are small
   scene-independent functions that take models and return results. Scenes call them and render
   feedback; they do not re-implement rules.
4. **Inventory changes are centralized transactions.** All item movement goes through the `Inventory`
   API, which validates first and then applies all-or-nothing: no negative counts, no exceeding
   capacity, no partial cooking.
5. **Saves are versioned.** A save is JSON with a `version` field; loading migrates or rejects unknown
   versions and sanitizes counts and ids. Transient things (guests in the room) are not saved.
6. **Signals for UI.** Models/`GameState` emit change signals; HUD and panels subscribe. No global
   event bus until a real need appears.

## Directory layout
| Path | Contents |
|---|---|
| `scenes/` | `.tscn` + co-located scene scripts (`main/`, `player/`, `props/`, `world/`, later `ui/`) |
| `scripts/autoload/` | autoload singletons |
| `scripts/world/` | scene-independent map logic: `MapGrid`, `DualGrid`, `CollisionRects` |
| `scripts/data/` | Resource class definitions *(planned)* |
| `scripts/systems/` | scene-independent rules and models *(planned)* |
| `data/maps/` | ASCII level layouts with a legend header |
| `data/` (other) | `.tres` definitions *(planned)* |
| `assets/` | art, fonts, audio — every file logged in [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md) |
| `tests/` | runner, framework, `unit/`, `integration/` |
| `tools/` | validation script; `tools/art/` placeholder asset generators (`python tools/art/build_all.py`) |

## Rendering and scale (provisional until the M1 benchmark is approved)
- Native viewport **640×360**, window 1280×720, `viewport` stretch + `integer` scale → no blurry or uneven pixels.
- Nearest-neighbour canvas filtering; 2D transforms and vertices snapped to pixels.
- Candidate grid: 32×32 tiles, ~48×64 character frames (per ART_BIBLE.md; validated in M1).

## Testing strategy
| Layer | What | Where |
|---|---|---|
| Unit | models and rules (inventory, cooking, orders, economy, saves) | `tests/unit/` |
| Integration | real scenes in the tree: movement, collisions, transitions, interactions, full loop | `tests/integration/` |
| Resource validation | every `.tscn`/`.tres` loads, every scene instances | `tests/integration/test_project_resources.gd` |
| Boot check | real main scene runs 300 frames headless without errors | `tools/run_tests.sh` |
| Visual check | Movie Maker captures of the real game at native resolution, inspected by eye | see DEVELOPMENT.md |
| Human playtest | feel, readability, pacing — cannot be automated | milestone reports |

The runner (`tests/test_runner.gd`) registers a `Logger`, so any engine or script error raised while a
test runs fails that test even if no assertion did.

## Decision log
Reversible choices made where the design docs were silent.

| Decision | Choice | Reason | Revisit when |
|---|---|---|---|
| Renderer | GL Compatibility | 2D-only game; widest hardware support; fast startup | 2D lighting/shader needs exceed it |
| Test framework | small in-repo runner | no network access for GUT/GdUnit; no plugin/version coupling | the suite outgrows it |
| Data registry | explicit preload lists in `GameDB` | export-safe and reviewable | content grows past a few dozen entries |
| Native viewport | 640×360 (2× = 720p, 3× = 1080p) | integer-scales to common displays; whole tavern fits one screen (see VISUAL_BENCHMARK.md) | owner benchmark review |
| Level authoring | ASCII maps in `data/maps/`, terrain built at load | fast iteration, diff-able, testable; furniture stays hand-placed | production tileset arrives (repaint in editor) |
| Terrain transitions | dual-grid with generated transition tiles | organic edges without configuring Godot terrain peering bits | production tileset uses Godot terrains |
| TileSets | created in code from atlas PNGs | no hand-maintained `.tres` for placeholder atlases | production tileset |
| Placeholder art | generated by `tools/art/*.py` from one palette | no network, no paid tools, clean provenance, reproducible | art source chosen after benchmark |
| UI font | in-repo bitmap font (BMFont), integer scaling only | crisp at 640×360; no licensing questions | UI art pass |
| Tall-prop readability | trees fade to 45% while the player is behind them | player never fully hidden in a dense forest | playtest feedback |
