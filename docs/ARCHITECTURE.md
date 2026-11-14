# Technical Architecture — Vertical Slice

Scope: the M0–M5 slice in [VERTICAL_SLICE.md](VERTICAL_SLICE.md). Keep this document in sync with the
code; sections marked *(planned)* do not exist yet.

## Shape of the game
```
Main (scenes/main)                persistent root: swaps world scenes, owns HUD + overlays
├── WorldSlot                     one World at a time: Tavern interior or Forest
│   └── World (scenes/world)      Ground TileMapLayer + Actors (Y-sorted: player, props, guests)
├── HUD (CanvasLayer 10)          coins, satchel, tavern status, prompt, toasts, inventory panel
├── Panels (CanvasLayer 20)       CookingPanel, UpgradePanel (player frozen while open)
├── TitleLayer (30)               TitleScreen: New Game / Continue / Quit over the live tavern
├── BannerLayer / FadeLayer       location banner, fade-to-black travel transition
└── PauseLayer (45, always runs)  PauseMenu: Resume / Save Game / Quit to Title

Autoloads (in load order)
├── GameDB                        read-only registry of data Resources (explicit preload list)
├── GameState                     mutable session state: inventories, coins, upgrades, nodes, ledgers
├── Feedback                      UI channel: toasts, panel requests, cooking state
├── SaveService                   versioned JSON save file, atomic writes
└── Audio                         named SFX voice pool + one looping ambience per world
```

### Saving, menus and audio
- `SaveData` (pure) captures `GameState` into a v1 JSON-friendly dictionary and applies one back:
  the version is checked before anything changes; unknown items, upgrades and worlds are dropped;
  counts must be positive whole numbers; coins are rebuilt from the earned/spent ledger when they
  disagree. Guests and the open state are never saved — a loaded game starts closed.
- `SaveService` writes to `user://savegame.json` via a temp file + replace and recovers an
  interrupted write. Autosave after every arrival and on Quit to Title; manual save in the pause menu.
- Launch shows the title over the live tavern (play time does not run). Esc opens the pause menu only
  when no panel consumed it first (panels are children of `Main`, so they see input earlier).
- `Audio.play(name)` from presentation scripts only; `Main` sets the ambience on arrival.

### Interaction and gathering
- `Interactable` (Area2D on layer 3) carries a `prompt` and `enabled` flag and emits `interacted`.
  The player's `InteractionSensor` (a circle just ahead of the feet in the facing direction) picks
  the nearest enabled one; the HUD shows its prompt; the interact action calls `try_interact()`.
- `GatherNode` keeps no state itself: `GameState.gather()` applies the `Gathering` rules (yield into
  the satchel up to free space, deplete, regrow after 120 s of play time) and stores the result by
  `node_id` (`forest:x,y`), so picks survive travel and (in M5) saves.
- `Inventory` is the only place counts change; `InventoryTransactions` handles multi-inventory moves
  (pantry deposit; cooking consumes pantry first, then satchel). Satchel and pantry objects live for
  the whole session — UI binds to them once.

### Cooking
- `RecipeData` (`data/recipes/`): `ingredients` (typed `Dictionary[StringName, int]`), `output` dish
  (`ItemData` of kind DISH with a `price`), `cook_seconds`.
- The hearth's `Interactable` asks `Feedback.open_panel(&"cooking")`; `Main` opens `CookingPanel`
  and freezes the player until it closes.
- `CookingPanel` shows have/need per ingredient and only enables recipes that can be cooked. A cook
  fills over `cook_seconds`; each interact press ("stir") adds 15%. Only on completion does
  `GameState.cook()` run `Cooking.cook()` — one transaction that validates everything, consumes
  (pantry first) and puts one dish in `GameState.counter`. Stopping early consumes nothing.
- The tavern `Counter` renders the dishes waiting in `GameState.counter`.

### Tavern service and economy
- `OpenSign` toggles `GameState.tavern_open`. `TavernService` (tavern scene) spawns a `Guest` only
  while open, when a `Seat` is free and `Orders.orderable()` is non-empty: dishes on the counter or
  cookable from the pantry/satchel after reserving ingredients for orders already placed. First
  arrival 3 s after opening, then every 9–14 s; at most 3 guests (one per seat).
- Archetypes alternate (`Orders.choose_archetype`); orders lean 3:1 towards favourites
  (`Orders.pick`). `GuestData` holds look, favourites, tip, patience (80–100 s) and lines.
- `Guest` state machine: ARRIVING (walks the seat's `approach` path) → WAITING (order bubble,
  patience bar; serve by interacting) → EATING → pays `Orders.payment()` (price + tip for a
  favourite) → LEAVING. Impatient guests leave politely without paying; nothing else is lost.
- Closing stops arrivals; seated guests can still be served. Walking out of the tavern closes it
  and the guests go home (guests are never saved).
- `GameState.earn/spend` keep `coins == coins_earned - coins_spent` and never go negative.
  `buy_upgrade` charges once and re-derives satchel capacity from owned upgrades.
  The notice board (`UpgradeBoard` → `UpgradePanel`) sells the Expanded Satchel (60 coins, +8).

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
| `scripts/data/` | Resource class definitions (`ItemData`, `RecipeData`, `GuestData`, `UpgradeData`) |
| `scripts/systems/` | scene-independent rules and models (`Inventory`, `InventoryTransactions`, `Gathering`, `Cooking`, `Orders`) |
| `data/maps/` | ASCII level layouts with a legend header |
| `data/items/`, `data/recipes/`, `data/guests/`, `data/upgrades/` | definitions (`.tres`) |
| `assets/` | art, fonts, audio — every file logged in [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md) |
| `tests/` | runner, framework, `unit/`, `integration/`, `playtest/` (agent + timed session), `visual/` (captures) |
| `tools/` | validation script; `tools/art/` placeholder asset generators (`python tools/art/build_all.py`) |

## Rendering and scale (provisional until the M1 benchmark is approved)
- Native viewport **640×360**, window 1280×720, `viewport` stretch + `integer` scale → no blurry or uneven pixels.
- Nearest-neighbour canvas filtering; 2D transforms and vertices snapped to pixels.
- Candidate grid: 32×32 tiles, ~48×64 character frames (per ART_BIBLE.md; validated in M1).

## Testing strategy
| Layer | What | Where |
|---|---|---|
| Unit | models and rules (inventory, cooking, orders, economy, saves, ledgers, audio) | `tests/unit/` |
| Integration | real scenes driven by input events: movement, collisions, travel, gathering, cooking, service, upgrade, menus, save/continue | `tests/integration/` |
| Full loop | `PlaytestAgent` plays the whole loop through player inputs (teleporting between targets) and checks the conservation ledgers | `tests/integration/test_full_loop.gd` |
| Timed session | the same agent walking everywhere (A* over physics-probed cells driving the move actions) | `tests/playtest/full_session.tscn` |
| Resource validation | every `.tscn`/`.tres` loads, every scene instances | `tests/integration/test_project_resources.gd` |
| Boot check | real main scene runs 300 frames headless without errors or leaks | `tools/run_tests.sh` |
| Visual check | captures from the real renderer at native resolution, inspected by eye | `tests/visual/capture_benchmark.tscn` |
| Human playtest | feel, readability, pacing — cannot be automated | [PLAYTEST_REPORT.md](PLAYTEST_REPORT.md) |

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
| Satchel capacity rule | total item count (base 10), not slots | simplest legible rule ("7/10"); upgrade raises the number | playtest feedback |
| Full satchel while gathering | take what fits; the rest stays on the node | no item loss, no prompts | — |
| Node regrowth | 120 s of play time after a node is emptied; partial nodes keep their remainder | supports repeat trips without a calendar or timers on screen | economy tuning in M4/M5 |
| Pantry | unlimited, deposit-all only | frees the satchel for the next trip; cooking reads it directly | storage upgrades (post-slice) |
| Cooking interaction | auto-filling 1.4–2.0 s cook; optional "stir" taps speed it up | tactile and legible without a mandatory minigame (GDD §5) | playtest feedback |
| When ingredients are consumed | on completion, atomically | cancelling or interruptions can never lose items | — |
| Dish storage | serving counter (`GameState.counter`), unlimited | cooking before or during service both work | playtest feedback |
| What guests may order | only dishes on the counter or cookable now (minus reserved) | no impossible orders; missing ingredients never surprise the player | more recipes / guests |
| Closing behaviour | no new arrivals; seated guests stay and can be served; leaving closes and sends guests home | predictable, no endless queue (TAVERN_MANAGEMENT.md) | playtest feedback |
| Patience | 80–100 s, leave politely, no penalty beyond the missed sale | forgiving pacing (GAMEPLAY_LOOP.md) | playtest feedback |
| Prices / tip / upgrade | soup 10, tart 14, stew 24; tips 4–6 on favourites; satchel 60 coins (+8) | upgrade affordable after ~4–5 served dishes, i.e. within a 10–15 min session | M5 playtest numbers |
| Guest variety | alternate archetypes (random first) | with two archetypes, random streaks hid one of them | more archetypes |
| Save trigger | autosave on arrival and on Quit to Title + manual save | no lost progress without save-slot UI | more save slots |
| Save format | JSON v1 with `migrate()` hook | human-readable, diff-able, easy to validate | size or tamper concerns |
| Coins on load | rebuilt from the earned/spent ledger if they disagree | keeps the economy consistent even with a damaged/edited save | — |
| Audio | synthesised placeholder SFX + ambience, volume constants in `Audio` | basic feedback and ambience per the slice contract, no licensing | audio direction / options menu |
