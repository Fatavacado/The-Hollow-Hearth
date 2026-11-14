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
| Benchmark screenshots | `docs/benchmark/*.png` | Captured from the game by `tests/visual/capture_benchmark.tscn` | Original | Project-owned | Yes | documentation |

## Generated-asset policy
- Assets produced by scripts in `tools/art/` are original work of this project. The script is the source;
  regenerate instead of hand-editing outputs, and list each output file group above.
- AI image outputs (GPT or similar) are concept references only until cleaned, validated in Godot and
  approved; log the tool, prompt summary and date.
- No purchased assets or paid API usage without explicit owner approval.
