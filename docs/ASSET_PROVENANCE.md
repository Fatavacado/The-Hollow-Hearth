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
| Copperfern art benchmark v001 (player 4-dir idle/walk, forest terrain/decor/tree/bush/glowcap/moonberry, tavern tiles/counter/table/chair/stove/fire/pot) | `assets/art/benchmark/copperfern/*` | Native pixels authored in `tools/art/copperfern/*.py` (2026-11-15); appearance follows HH-CONCEPT-002 and the approved top-down reference, no pixels copied or downscaled from them | Original | Project-owned | Yes | benchmark |
| Copperfern benchmark captures, GIFs and contact sheets | `docs/art/benchmark/copperfern_v001/*` | Captured from the game / built from the assets above | Original | Project-owned | Yes | documentation |
| Benchmark screenshots | `docs/benchmark/*.png` | Captured from the game by `tests/visual/capture_benchmark.tscn` | Original | Project-owned | Yes | documentation |

## Generated-asset policy
- Assets produced by scripts in `tools/art/` are original work of this project. The script is the source;
  regenerate instead of hand-editing outputs, and list each output file group above.
- AI image outputs (GPT or similar) are concept references only until cleaned, validated in Godot and
  approved; log the tool, prompt summary and date.
- No purchased assets or paid API usage without explicit owner approval.

---

# Art-direction rights ledger (from main)

Status: research and original exploratory concepts only. No third-party game pack was imported, committed or licensed for reuse. No software purchase, subscription or paid sprite API was used. The available image-generation tool was used for the requested exploratory board; no separate paid service was acquired.

| ID / file | Creator / source | Rights evidence | Changes / intended use | State |
|---|---|---|---|---|
| HH-CONCEPT-001 — docs/art-direction/concept-comparison.png | OpenAI image-generation tool, prompted for this task on 2026-11-14 | Generated in this session; applicable service terms govern use. No exclusive rights, clearance or jurisdiction-specific copyright claim established. | Original three-row character/forest/tavern proposal; no third-party image inputs. Source output retained at /workspace/generated_images/exec-84d116c9-8d4a-4719-9e27-d429f1bac722.png. Copied unchanged for review. | Exploratory only; row B selected as the main-region direction on 2026-11-14. Individual pixels/assets are not approved sprites or tiles. |
| Research prose, style specifications and skill | Codex/Claude-compatible agent workflow for this repository | New project documentation; repository ownership/terms apply. | Informed by named references and explicitly separated from copied assets. | Draft for review. |
| Pixel Crawler / Anokolisa | https://anokolisa.itch.io/pixel-crawler | License inaccessible/unverified; pack not acquired. | Inspiration only; no downloaded pack, extracted art or redistribution. | Not authorized as a production dependency. |
| Eastward / Moonlighter / Children of Morta / Stardew Valley / Sea of Stars | Official links in ART_DIRECTION_RESEARCH.md | No asset reuse license established. | Comparative technique discussion only. No screenshots copied into repo. | Reference only. |
| Ashbound Wayfarer | Original approved source not available | Unknown; no source image examined. | Quality benchmark mentioned in existing bible only. | Locate approved original before use. |

## Tool licensing is separate from asset licensing

LibreSprite README states GPL v2, Pixelorama README states MIT, and Aseprite has a proprietary EULA. These govern tools; they do not grant commercial reuse rights to any bundled/example/third-party artwork. Do not assume editor licensing makes every exported image redistributable. Record external brushes/fonts/plugins separately. PixelLab terms, current prices and commercial-output conditions were inaccessible and remain unverified. No PixelLab call made.

## Required record for every future asset

```yaml
asset_id: hh_actor_example_walk_v001
status: draft # approved only after review
path: art/export/characters/example/walk.png
source_path: art/source/characters/example/example_v001.aseprite
creator: human-or-tool-and-operator
created_utc: YYYY-MM-DD
source_url: original-or-authoritative-url
license: exact-name-version-or-contract
license_evidence: stored-license-path-or-permalink
commercial_use: verified-or-pending
modification: verified-or-pending
redistribution: verified-or-pending
attribution: exact-required-text-or-none-verified
ai_assistance: tool-version-prompt-reference-and-input-IDs
changes: original-work-or-edit-description
sha256: calculated-export-digest
style_revision: copperfern_main_direction_selected_2026_11_14 # technical benchmark pending
reviewer: pending
```

Unknown rights means reference-only/quarantine, never production. Keep license text, invoice if any, acquisition date and immutable evidence alongside source records without exposing credentials. Review derivative inputs, likeness/trademark issues, font licensing and platform-specific distribution requirements. Owner approval of appearance does not resolve rights. Attribution should be accumulated for credits but not used as a substitute for permission.

## Concept generation recipe

One board, 3 rows × 3 columns: Hearthglass Orchard, Copperfern Guild, Moonmilk Folk; each row character down/side/back studies, sunny forest, inviting tavern with two friendly supernatural guests. Explicit top-down three-quarter rectangular-grid perspective; same intended camera, path, actor size and tavern arrangement. Specify each direction's shape grammar, wardrobe, materials and palette from ART_STYLE_EXPLORATIONS.md. Request original designs, no existing game characters or artist imitation, and label exploratory only. Generated output is nondeterministic: preserve the actual output and prompt intent; do not promise seed-reproducibility. Validate and hand-correct separately.

The generator delivered 1536×1024 presentation art. No transparency, exact palette, seamless edges, sprite registration, animations or production dimensions are asserted. See the candid visual review in ART_STYLE_EXPLORATIONS.md.

Concept PNG SHA-256: `85021068cecd0a6b95dd43e996ad686f77f2ce3ed4bc161e947224be61b0572f`.

Pixelorama 1.2.4 official release installed outside the checkout for tool evaluation; bundled sample art remains outside the project. PNG round-trip fixture is procedural QA data, not a game asset. See pipeline for verified scope and diagnostic limitations.

## HH-CONCEPT-002 — Copperfern player study 01

File: `docs/art-direction/copperfern-player-study-01.png`; brief and review: `docs/art-direction/PLAYER_DESIGN.md`. Generated with the available OpenAI image tool on 2026-11-14, no reference-image inputs. Prompt requested an original compact traveler/tavern keeper in teal rolled sleeves, russet split apron, ingredient satchel, brass clasp and broad boots; front/side/back plus gather/serve studies, Copperfern palette and non-isometric three-quarter perspective. Appearance and wardrobe are proposals, not established lore. Source output retained at `/workspace/generated_images/exec-cdeb2477-5da2-450e-943e-6ed8ccd8a93e.png`, copied unchanged. Applicable service terms govern use; no exclusivity or legal clearance claimed. Status: individual character approval pending; conceptual reference only. No exact native dimensions, complete animation, in-game integration or frame registration claimed.

## HH-SPRITE-PROTOTYPE-001 — Copperfern south idle

Files: `docs/art-direction/sprite-prototypes/`. Original image tool generation from HH-CONCEPT-002, then ImageMagick native-frame conversion and three readability pixel corrections, detailed in the adjacent README. 48×64 binary-alpha static PNG; 8× review preview separate. No third-party input added. Same service-term limitations as concepts; prototype approval pending. Not animated or validated in Godot.

## HH-CONCEPT-003 — Copperfern environment study 01

File: `docs/art-direction/copperfern-environment-study-01.png`; brief/review: `docs/art-direction/ENVIRONMENT_DESIGN.md`. Generated with the available OpenAI image tool for this task, no image inputs. Prompt specified an original bright compact forest, timber/plaster tavern exterior, readable one-room interior, Copperfern materials/palette and top-down three-quarter rectangular-grid perspective. Original output retained at `/workspace/generated_images/exec-81a5c012-77fd-4591-937b-a822547a5001.png`, copied unchanged. Applicable service terms govern use; no exclusive rights or clearance claimed. Concept review pending, not tiles, production assets, a playable map or approved new gameplay content.

## HH-CONCEPT-004 — Copperfern environment asset study

File: `docs/art-direction/copperfern-environment-assets-study-01.png`; brief/review: `docs/art-direction/ENVIRONMENT_ASSET_STUDY.md`. Original image-tool generation, no image inputs. Prompt specified isolated terrain, path transitions, vegetation, modular building parts and furniture in the selected Copperfern visual language, with transparency and no existing game assets. Source retained at `/workspace/generated_images/exec-f0d167e2-67fc-4fe8-a1b0-bda6cd9c54eb.png`, copied unchanged. Applicable service terms govern use; no exclusivity or clearance claimed. Visual study only: exact native dimensions, seam compatibility, complete transitions, engine import and gameplay scale are unverified. Not a production atlas or future-region asset commitment.

## PC-REFERENCE-001 — uploaded Pixel Crawler free pack

Creator: Anokolisa. User-provided archive `Pixel Crawler - Free Pack (Exterior 0.1).zip`, retained under workspace attachments; selected reference files inspected outside Git. Included Terms.txt permits functional use including commercial products and alteration, says attribution is optional/appreciated, and prohibits selling assets as a final asset product without permission. Raw source-repository redistribution permission was not established. No extracted assets added to this repository or integrated into the game. See PIXEL_CRAWLER_REFERENCE_REVIEW.md for sampled dimensions and exact review scope. This entry supersedes the earlier statement that this edition's license was inaccessible; the storefront remains unverified.

## HH-SPRITE-PROTOTYPE-002 — tiny native Copperfern study

Original agent-authored pixel matrix and palette, rendered via Pillow at 16×30 (visible 13×30), with padded 64×64 runtime candidate and nearest-neighbor 12× review image. Source and outputs in `docs/art-direction/sprite-prototypes/`; no Pixel Crawler pixels used. Separate optional image-tool concept used HH-CONCEPT-002 as input and remains in generated_images; its coarse illustration is not the native sprite. Appearance/style approval and animation/engine validation remain pending. No reference pack source redistributed.

## Current visual selection after tiny comparison

The owner chose to retain the original Copperfern character/environment treatment. HH-CONCEPT-002 and HH-SPRITE-PROTOTYPE-001 remain active appearance/scale references, with HH-CONCEPT-003/004 supplying environment vocabulary. HH-SPRITE-PROTOTYPE-002 is an archived unselected scale experiment. Selection records visual intent, not technical readiness, blanket asset approval or changed rights.

## HH-REFERENCE-005 — original selected high top-down reference (superseded in brightness)

Historical file version in commit `c1600fb`: `docs/art-direction/copperfern-approved-top-down-reference.png`. Owner approved this original Copperfern high top-down visual direction and authorized publication to main. Generated image-tool output, source `/workspace/generated_images/exec-e4fe1b40-e7e5-4305-80b8-a656283867c0.png`, copied unchanged. Inputs: Anokolisa's Tavern.png from the uploaded pack as camera/pixel-construction reference, and the original generated Copperfern player study as appearance reference. Prompt requested new original layouts/designs, not copying reference assets. This is image synthesis, not an actual engine screenshot or an extracted/composited pack atlas; reference influence and applicable service/input terms remain relevant. No exclusive ownership or rights clearance claimed. Included mockup chef, guest appearances, UI and room arrangement are illustrative, not approved gameplay additions. The raw pack and its example images are not committed. Production assets still require original native artwork, provenance and technical validation.

## HH-REFERENCE-006 — approved brighter starting-region revision

Current file: `docs/art-direction/copperfern-approved-top-down-reference.png`. The owner reviewed the brighter candidate and approved the update. Original image-tool palette/lighting edit, with HH-REFERENCE-005 as its sole image input. Source output: `/workspace/generated_images/exec-d589f8e2-747d-4bf7-b41e-e24c288759f8.png`, copied unchanged. Prompt requested brighter spring greens, sandy paths, turquoise water, ivory plaster and honey wood while preserving the high camera, Copperfern identity and layout. Stardew Valley was a mood comparison only, not an image input or requested asset imitation. Minor generated detail changes remain illustrative, not gameplay requirements. Source-reference influence and applicable service/input terms from HH-REFERENCE-005 still apply; no exclusive ownership or legal clearance claimed. This is a selected visual mockup, not an actual Godot screenshot, indexed palette, validated lighting configuration or production tile atlas. The earlier darker image is preserved in Git history.
