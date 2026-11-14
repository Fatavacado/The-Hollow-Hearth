# Asset Provenance Log

Every asset in the repository is listed here **before** it is committed. Columns follow
[ART_BIBLE.md](ART_BIBLE.md#asset-sourcing): creator, source, license, modification rights and usage.

**Status values:** `placeholder` (temporary, replace before release) · `benchmark` (under visual review) ·
`approved` (passed the benchmark gate) · `rejected`.

| Asset | Path | Creator / tool | Source | License | Modifiable | Status |
|---|---|---|---|---|---|---|
| Project icon (hearth arch + flame) | `icon.svg` | Hand-written SVG in this repo | Original | Project-owned | Yes | placeholder |
| "Hearth Pixel" bitmap UI font (glyph designs + BMFont) | `assets/fonts/hearth_pixel.*` | `tools/art/gen_font.py` | Original | Project-owned | Yes | benchmark |
| Player, vampire and ghost sprite sheets | `assets/art/characters/*.png` | `tools/art/gen_characters.py` | Original | Project-owned | Yes | benchmark |
| Forest terrain (dual-grid) + decor tiles | `assets/art/tiles/forest_*.png` | `tools/art/gen_world.py` | Original | Project-owned | Yes | benchmark |
| Forest props (oaks, pine, bush, rock, stump) and tavern exterior | `assets/art/props/{oak_tree_a,oak_tree_b,pine_tree,bush,rock,stump,tavern_exterior}.png` | `tools/art/gen_world.py` | Original | Project-owned | Yes | benchmark |
| Tavern interior tiles | `assets/art/tiles/tavern_tiles.png` | `tools/art/gen_tavern.py` | Original | Project-owned | Yes | benchmark |
| Tavern furniture (hearth, fire, cauldron, counter, table, stool, barrel, crate, shelf, window, notice board, signs, pantry chest, rug, plant, wall lantern) | `assets/art/props/*.png` (remaining files) | `tools/art/gen_tavern.py` | Original | Project-owned | Yes | benchmark |
| Item icons (5 ingredients, 3 dishes, coin, satchel) | `assets/art/items/*.png` | `tools/art/gen_items.py` | Original | Project-owned | Yes | placeholder |
| Gather-node sprites, full + picked (glowcap, moonberry, fernleaf, sweetroot, honeycomb) | `assets/art/nodes/*.png` | `tools/art/gen_items.py` | Original | Project-owned | Yes | placeholder |
| Guest UI sprites (order bubble, heart and sad emotes) | `assets/art/ui/*.png` | `tools/art/gen_items.py` | Original | Project-owned | Yes | placeholder |
| Sound effects (pickup, store, stir, cook done, coin, bell, door, ui, buy) and forest/tavern ambience loops | `assets/audio/*.wav` | `tools/art/gen_audio.py` (synthesised) | Original | Project-owned | Yes | placeholder |
| Gameplay screenshots and agent session report | `docs/screens/*` | Captured from the game | Original | Project-owned | Yes | documentation |
| Benchmark screenshots | `docs/benchmark/*.png` | Captured from the game by `tests/visual/capture_benchmark.tscn` | Original | Project-owned | Yes | documentation |

## Generated-asset policy
- Assets produced by scripts in `tools/art/` are original work of this project. The script is the source;
  regenerate instead of hand-editing outputs, and list each output file group above.
- AI image outputs (GPT or similar) are concept references only until cleaned, validated in Godot and
  approved; log the tool, prompt summary and date.
- No purchased assets or paid API usage without explicit owner approval.

## Codex v2 — independent Copperfern visual benchmark (pending approval)

Branch `feat/art-codex-v2`, frozen playable baseline `a8085de`, reference main commit `c1600fb`. This candidate is independent of Claude's new artwork. No Pixel Crawler or other asset pack was used, extracted or modified for these runtime assets. Existing baseline scenes, layouts and semantic atlas contracts were retained, not another candidate's artwork.

| Candidate family | Creation / editable source | Runtime outputs |
|---|---|---|
| Player directional rig | Available image-generation tool, original Copperfern four-view study retained in `assets/art/source/codex_v2/player_directions.png`; native palette cleanup, arm/leg articulation and asymmetric satchel registration in `tools/art/codex_v2_player.py` | `assets/art/characters/player.png`, 5×4 cells of48×64; four directional idle/walk states |
| Hero trees, facade and woodland props | Original source study `woodland_props_source.png`; explicit crops, binary-alpha cleanup, material palette reduction, native-size silhouette corrections and original doorway redraw in `tools/art/codex_v2_props.py` | oak_a/oak_b/pine, bush, stump and tavern_exterior PNGs; original baseline canvas and ground rows |
| Tavern furniture/equipment | Original source study `tavern_props_source.png`; native conversion and cooking overlay socket cleanup in `codex_v2_props.py` | table, stool, barrel, counter, pantry, shelf, hearth, window; separately authored native crate/rug |
| Terrain and wall atlas | Original deterministic pixel code in `tools/art/codex_v2_terrain.py`, no image inputs | forest_terrain, forest_decor, tavern_tiles; unchanged 32px atlas semantics |
| Gatherables and small vegetation | Original native silhouettes, material ramps and full/harvested states in `tools/art/codex_v2_gathering.py`, no image inputs | five full/empty ingredient nodes, plant, rock |

Image-generation source IDs: player `exec-3e7ddf0e-c576-4706-82a8-bc1f9697f71a`; woodland `exec-dbfacd67-1bfe-4f55-a9fa-817b1616f5b1`; tavern `exec-35a75493-61b2-4d5f-b21e-e8b5e5a8a0ff`. Original high-resolution source studies are not production sheets. Runtime files are cleaned/native exports; code retains crop coordinates, dimensions, palettes and ground anchors. Tool and source/input service terms remain applicable; generation does not imply exclusive copyright or independent legal clearance. No purchases, subscriptions or paid external sprite API calls were made.

See `assets/art/source/codex_v2/provenance.json` for SHA-256s and modified-output inventory, and `docs/CODEX_ART_V2.md` for actual engine evidence and limitations. These additions supersede the earlier blanket placeholder description only for the listed files. Unchanged guest art, UI, icons, audio and other baseline assets retain their existing records. All new art is a review candidate, not owner-approved production content.
