# Art production pipeline

## Approved starting-region palette and lighting

The owner approved the brighter Copperfern revision. Use fresh spring greens with golden leaf highlights, light sandy/ochre paths, clear turquoise water, warm ivory plaster and honey-colored timber/floorboards. Keep teal roofs/shutters, cheerful terracotta/russet fabrics and small copper/brass accents. Match the current `docs/art-direction/copperfern-approved-top-down-reference.png`; earlier muted/dark studies are secondary references and must not override its daylight values.

Preserve crisp pixel edges, dark selective outlines, character/prop separation and readable contact shadows. Darkness belongs in localized canopy/occlusion shadows and later intentionally mysterious areas, not as a starting-region color wash. The tavern is bright with ambient/window daylight and localized hearth warmth; avoid both dark sepia and a blanket orange tint. Do not simply raise exposure or saturation until materials lose contrast. Stardew Valley is a cheerful daytime mood reference only; create original palette ramps and artwork, without copying its sprites or designs.

Keep the approved high top-down camera and shared regional style contract. This is visual palette approval, not a locked indexed palette, exact swatch list, runtime lighting configuration or production-assets validation. Future regions retain room for intentional atmospheric contrast.

## Current approved visual reference

The owner selected the **original Copperfern art with a high top-down RPG camera** and authorized publication to main for future developers. Read [the reference guide](ART_REFERENCE.md) and inspect `docs/art-direction/copperfern-approved-top-down-reference.png` before drawing or integrating art. This current camera/scene reference supersedes the lower, frontal environment illustrations. Preserve the original character's identity while fitting it to the higher camera and coherent actor/room scale. Earlier numerical profiles are candidates, not locked production geometry. Pixel Crawler informed camera/construction research only; use original art, not its asset pack as the game's default dependency.


Status: Copperfern Guild selected by the owner for the main region; production benchmark pending. Read [ART_BIBLE.md](ART_BIBLE.md), [ART_STYLE_EXPLORATIONS.md](ART_STYLE_EXPLORATIONS.md) and [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md). Approved perspective remains 2D top-down / three-quarter on rectangular tiles, never isometric. **Copperfern Guild** governs the main-region direction. Read [ART_REGIONAL_STYLE.md](ART_REGIONAL_STYLE.md) for shared rules and regional variation. Dimensions, swatches and timing must pass a small playable benchmark before becoming standards.

## Current capabilities and limits

Checked in this cloud environment on 2026-11-14:

| Tool | Actual availability | Proposed use and constraints |
|---|---|---|
| Godot | `/usr/local/bin/godot`, also `godot4`; 4.6.3 verified during onboarding | Scene import, animation, collision and sorting validation. User reports a 4.7.2 vertical slice, but this checkout and runtime do not establish it; inspect that slice and its engine before integration. Do not migrate settings to fit this runtime. |
| Aseprite | CLI not on PATH | Recommended manual source editor if legally available. Paid official binaries; source has its own EULA, not a blanket open-source redistribution grant. No purchase or install performed. |
| LibreSprite | CLI not on PATH | Potential free GPL editor; evaluate current release, OS support and required export features before adopting. |
| Pixelorama | Downloaded official v1.2.4 Linux x86_64 release outside checkout | Launched headlessly; PNG import/export preserved all RGBA pixels in a 16×16 fixture. Startup emitted shader compiler and duplicate-signal errors; graphical drawing and animation export remain unverified. See local commands below. |
| PixelLab | No connected PixelLab tool found | Optional assisted sprite/animation route only after capability, commercial terms, costs and approval are checked. Do not assume a subscription or call a paid API. |
| Image generation | Tool exposed in this conversation | Exploratory references only. Check spending authorization before chargeable use; generated illustration does not prove clean pixel clusters, tiling, directional registration or rights clearance. |
| Python + Pillow | Both available | Reproducible palette, bounds, alpha, frame extraction and contact-sheet analysis; cannot replace art judgment. |
| ImageMagick / FFmpeg | `convert`, `magick`, `ffmpeg` on PATH | Contact sheets and preview videos; retain nearest-neighbor scaling and exact frame duration. |

Sources for tool and engine terms: [Aseprite FAQ](https://www.aseprite.org/faq/), [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt), [LibreSprite](https://github.com/LibreSprite/LibreSprite), [Pixelorama](https://github.com/Orama-Interactive/Pixelorama), [PixelLab](https://www.pixellab.ai/), [Godot license](https://godotengine.org/license/), [Pillow license](https://pillow.readthedocs.io/en/stable/about.html#license), [ImageMagick license](https://imagemagick.org/script/license.php), [FFmpeg legal](https://ffmpeg.org/legal.html). Tool licenses govern tools; imported brushes, fonts, models and artwork require their own records. Recheck current pricing/terms before acquisition; no current price or online account access is claimed here.

## Working contract and file layout

Inspect `git status --short` and existing asset conventions first. Use `feat/art-direction-research` for research. Do not reset or overwrite unpushed work, existing assets, gameplay or project settings. Locate the reported vertical slice before choosing its integration paths. No raw commercial reference packs in Git.

Proposed paths below are templates, not directories to create before approval:

```text
art/source/characters/player/player_v001.aseprite
art/source/environment/forest/terrain_v001.ora
art/source/props/tavern/oven_v001.aseprite
art/palettes/copperfern_candidate_v001.gpl
art/metadata/player_v001.json
assets/art/characters/player/player_walk_v001.png
assets/art/environment/forest/terrain_v001.png
docs/art/reviews/2026-11-14_player_v001.md
```

Preserve editable layered source in an editor-supported format (Aseprite, ORA or native Pixelorama); export PNG RGBA with stable frame bounds. Use lower-case snake_case and semantic names: `{subject}_{action}_{variant}_vNNN.png`. Metadata records the actual editor/version and export recipe. Keep directions in metadata even when a sheet visually suggests them.

## Candidate specification

Use 640×360 native comparison views, 32×32 terrain cells and 48×64 character frames as a **test profile**, not an approved project change. Character drawn height about 44–50 pixels, feet anchor `(24,58)` measured from frame top-left. A frame cell is a container, not a promise the sprite fills it. Keep source pixels at 1:1 and compare at integer 2×/3× using nearest neighbor. No automatic upscale to disguise inconsistent density. Test the alternate 480×270 viewport from the bible before final approval.

Selected Copperfern language: compact practical silhouettes, stepped fern/conifer masses, horizontal timber braces, russet cloth, spruce teal and restrained brass/copper highlights; quiet ground clusters around precise interaction silhouettes. Copper is a material accent, not a metallic tint applied to the entire world. Structural materials receive 3–4-value ramps; limited emissive accents and one restrained shadow family unify daylight and interior work. Final hex colors belong to the reviewed exploration palette. Do not silently invent a second palette during production.

## Asset workflow

1. **Brief and silhouette:** write role, native size, view, animation needs and neighboring reference IDs. Draw three black silhouettes without reference sprites underneath. Give the player a readable apron/satchel profile and a distinct hair/head shape; verify tool and carrying states do not conceal facing. Choose one through a 1× test over grass, floor and dark forest. Retain rejected sketches as original design evidence.
2. **Four directions:** block south, west, east, north separately. Keep head mass, torso volume and feet plane consistent. Do not blindly mirror asymmetric utensils, satchels or handed actions. Candidate walk sheet: six columns, rows `south, west, east, north`; 288×256 total for 48×64 cells. Keep idle in a separate two-column, four-direction-row sheet (96×256) with explicit metadata. Begin with two-frame idles and six-frame walks, approximately 2 and 8 fps respectively, then tune by measured ground speed. Contact frames carry weight; no accidental foot sliding.
3. **Terrain:** author a small family of grass, path and soil with interior, straight edge, outer corner and inner corner variants. Select the actual Godot terrain connectivity mode before drawing its atlas. Hand-label terrain bits; never assume one atlas arrangement fits every mode. Tile a 3×3 and 8×8 patch, include all border transitions, and inspect repeated motifs plus seams at 1×. Preserve quiet traversable ground; decorative variants cannot change implied collision.
4. **Vegetation and architecture:** establish trunk/door/furniture scale against the player before detail. Build trees as ground anchor, trunk and canopy layers, with separate foreground coverage where necessary. Use rectangular footprints, visible roof/front-wall planes and a consistent three-quarter face-depth rule. Avoid skewed diamond floors. Place leaf clumps and branch forks as deliberate clusters, not uniform noise. Reserve rare bright blooms for navigational and ingredient accents.
5. **Tavern props:** define chair seat, table surface, counter and cooking-station height with a common character overlay. Give each station a recognizable silhouette and state cue independent of hue. Countertops must allow hands and carried dishes to read. Draw front/back/side variants only when the actual placement system needs them. Separate oven glow/steam from opaque body and keep working space visibly clear.
6. **Supernatural guests:** start from hospitality role and personality, then one supernatural shape rule. Example original briefs: a compact coal spirit with a small warm face; a mushroom scholar with a brim-like cap and book-shaped satchel. Keep eyes, order bubble and facing readable; transparency must not erase feet anchors. Do not reuse another game's character silhouette or infer that supernatural implies threatening.
7. **Effects:** create anticipation, event and fade phases for gathering chips, cooking steam and spell wisps. Start with 4–6 frames; define duration in milliseconds, source point, draw layer and maximum footprint. Cluster particles into discrete readable pixels. Show direction and completion without obscuring ingredients or order UI. Avoid default additive bloom until native-resolution readability and accessibility are reviewed; avoid flashing patterns.
8. **Animation registration:** use the same canvas and anchor for every frame and direction; no automatic trim without exported offset metadata. Overlay frames at low opacity; inspect alpha bounds, contact frame feet, held-prop sockets and directional volume. Preview at intended fps and gameplay movement speed. Loop first/last transitions and action cancel states. Keep collision stable unless gameplay explicitly requires a separate approved change.
9. **Palette and density:** use the selected candidate swatches as named ramps with material roles. Inspect in grayscale; player and interactables must separate from background by shape/value, not just saturation. Review red/green confusion and dim scenes. Count colors as a diagnostic, not an arbitrary art-quality score; generated anti-aliasing and alpha fringes require manual correction. A tiny prop does not receive a denser rendering style than the player.
10. **Export:** retain editable source, export transparent RGBA PNG at native dimensions, no interpolation or lossy compression. Strip hidden reference layers. Record width, height, frame dimensions, rows, direction order, frame durations, anchor and palette revision. Verify dimensions divide by cell size and confirm every expected nonempty frame. Export a labeled contact sheet separately from runtime artwork.
11. **Godot integration:** only in a separately authorized integration change after locating the actual project. Inspect existing import/texture policy; use nearest filtering, lossless textures and avoid mipmaps for pixel sprites where consistent with project rules. Do not globally alter project settings in this research task. Configure `SpriteFrames` with explicit names such as `walk_south`, exact cell regions, frame duration and looping. Keep the actor origin at feet; draw sprite offset from that origin. Use foot-level collision shapes, not full canopy or full character bounds. Verify actual scene-tree Y-sort behavior and wall/canopy occlusion; a sprite's pretty pivot does not prove sorting works. Godot 4 uses `TileMapLayer`; inspect the slice's existing implementation rather than migrating it automatically.
12. **Quality review:** compare character, forest and tavern together at native scale and a common integer scale. Walk behind/in front of trees, counters, guests and doorways in all directions. Verify collision, ingredient affordances, path clearance, cooking state, carried dish and order readability. Check day, warm interior and twilight without allowing mystery to dominate the bright default. Reimport with the project's exact engine and inspect errors. Headless import is necessary technical evidence but does not establish visual success.
13. **Provenance:** create one record per source asset or original batch using [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md). Record creator, source URL, license evidence, commercial/modification/redistribution rights, attribution, tools/model/date, source file, modifications, reviewers and actual approval state. No license means quarantine. Inspiration links never imply asset permission.

## Practical inspection recipes

Run from the repository root with approved output paths. These commands inspect existing files, not generate final art:

```bash
# Exact pixel dimensions and channels:
magick identify assets/art/characters/player/player_walk_v001.png
# Inspect the first 48x64 cell at 4x without introducing blended pixels:
magick assets/art/characters/player/player_walk_v001.png -crop 48x64+0+0 +repage -filter point -resize 400% /tmp/player_cell_review.png
# Actual project import; use the slice's verified executable, not an assumed version:
godot --headless --path /path/to/verified/project --editor --quit
```

Dimensions, nonempty alpha and bounds can be checked in Pillow without treating the result as art approval:

```python
from PIL import Image
image = Image.open("player_walk_v001.png").convert("RGBA")
assert image.size == (288, 256)
for row in range(4):
    for col in range(6):
        frame = image.crop((col*48, row*64, (col+1)*48, (row+1)*64))
        assert frame.getchannel("A").getbbox(), (row, col, "empty frame")
```

## Brief, metadata and prompt templates

```text
Asset ID / owner / revision:
Status: exploration | benchmark | approved | rejected
Direction and palette revision:
Role; scene neighbors; native frame/tile size:
Foot anchor; collision footprint; occlusion layers:
Actions/directions/frame count/durations:
Tools/source files/export command:
Reference IDs and rights record:
Acceptance evidence / reviewer / outstanding issue:
```

```json
{"id":"player_walk_v001","status":"exploration","frame_size":[48,64],"sheet_size":[288,256],"rows":["south","west","east","north"],"columns":6,"fps":8,"anchor":[24,58],"palette":"copperfern_candidate_v001","source":"art/source/characters/player/player_v001.aseprite","license_record":"HH-ORIGINAL-PLAYER-001"}
```

Concept prompt: “Original Hollow Hearth orchard innkeeper, top-down three-quarter non-isometric view, rounded apron silhouette, asymmetric seed satchel, pottery shapes and branch-fork clasp, bright leaf-and-amber material relationships, readable at a proposed 48×64 gameplay frame. Show south/west/east/north studies on a neutral ground. No existing game characters, text labels or claims of animation-ready output. Exploration only.”

Environment prompt: “Original rectangular-grid forest and inviting tavern interior, same player scale and camera, quiet walkable ground, clustered orchard foliage, amber glass vessels and carved branch joinery, clear ingredient/station silhouettes. Bright daylight forest and warm interior; no isometric diamonds, painted blur, copied architecture or finished-tileset claim.”

Treat prompts as briefs. Manually redraw clusters, fix perspective, split layers, test tiling and register animation; image generation does not complete those steps.

## Approval gates and production budget

- **G0 rights and brief:** source legality documented; original silhouette and approved perspective; no chargeable tool use without permission.
- **G1 direction review:** Copperfern Guild selected for the main region on 2026-11-14. Keep exact asset/technical approval separate. Future regional directions need their own bounded review; publication alone is not approval.
- **G2 playable benchmark:** one player with four-direction movement, one compact forest and one tavern interior/entrance in a real scene flow. Confirm native scale, sorting, collisions, imports and gameplay readability with captured evidence. Existing gameplay must remain intact.
- **G3 reusable kit:** only after G2, approve one terrain transition family, one prop family and one guest. Record actual time per asset/frame before predicting full-game cost.
- **G4 batch acceptance:** validate every export; review a contact sheet and representative in-game scene; record approval and rework. Do not trade consistency for batch count.

For solo feasibility, prefer modular terrain, limited reusable material ramps, few hero props and deliberate animation caps. Measure the benchmark first; frame count multiplied by directions, actions and variants is the real workload. No promise of a cheap fully animated cast follows from one attractive static concept.

## Pixelorama local experiment (performed)

Downloaded the official [v1.2.4 Linux release](https://github.com/Orama-Interactive/Pixelorama/releases/tag/v1.2.4) over verified HTTPS, extracted outside the checkout. No bundled brushes or palettes were copied into the project. Executable:
`/workspace/.environment/tools/pixelorama-1.2.4/Pixelorama-Linux-64bit/Pixelorama.x86_64`.

Initialize the writable `XDG_CACHE_HOME`, `XDG_CONFIG_HOME`, `XDG_DATA_HOME` paths under `/workspace/.environment/{cache,config,data}` before launching. Local 16×16 transparent checker fixture and export are in `/workspace/.environment/art-research/`. Tested command:

```sh
/workspace/.environment/tools/pixelorama-1.2.4/Pixelorama-Linux-64bit/Pixelorama.x86_64 --headless /workspace/.environment/art-research/tool-input.png --export --output /workspace/.environment/art-research/tool-output.png
```

Pillow verified identical size and exact RGBA bytes after export. The process remained running and was stopped after checking output. Headless startup reports shader compiler errors and import reports duplicate signal connections; export success is narrower than an error-free editor claim. A prior `--editor` launch was invalid for this exported application and was replaced with application arguments verified in its tagged Main.gd source. Do not reuse `--editor`. The app bundles Godot 4.7.1; that does not replace the project engine or validate the claimed 4.7.2 slice.

Archive SHA-256: `692473e44fe90ea02de49048343d6b3cb86749b7beb166286dbc3a308c568e0b`. This is a locally calculated audit fingerprint, not a publisher-supplied checksum; no signature/checksum comparison is claimed. TLS verification stayed enabled. Use Pixelorama for a manual evaluation next, with PNG round-trip already demonstrated; graphical authoring, multi-frame export, palette retention and production sheet alignment still need testing. Tool installation lives outside Git and is not a repository dependency or new environment publication.

## Current owner decision: retain original Copperfern art

After viewing the tiny-size comparison, the owner chose to keep the **original Copperfern art first**. This supersedes the proposed switch/comparison to Pixel Crawler's small visible-character scale as the next production baseline. Preserve the original character's expressive curly-hair silhouette, teal rolled sleeves, cream undershirt, russet apron, satchel and sturdy boots, together with the detailed Copperfern forest/tavern material language.

Use these repository-root visual references:

- `docs/art-direction/copperfern-player-study-01.png`: original character appearance and wardrobe reference.
- `docs/art-direction/sprite-prototypes/copperfern_player_idle_south_v001.png`: original larger 48×64 frame prototype for runtime-scale comparison.
- `docs/art-direction/copperfern-environment-study-01.png`: forest/exterior and tavern material/composition reference.
- `docs/art-direction/copperfern-environment-assets-study-01.png`: environment asset vocabulary; requires native redraw and tile validation.

The tiny `copperfern_player_tiny_*` sprites and 16×16-grid proposal are archived experiments, **not the active style or production target**. Do not shrink or redesign new art to match them, reopen the tiny-scale comparison automatically, or let it override the selected original visual identity. Continue with the larger candidate profile: 32×32 terrain, 48×64 character frames, approximately 44–50 visible character pixels high and a 640×360 comparison viewport; final dimensions still require actual Godot validation. Preserve detail through deliberate native pixel construction, not smooth illustration downscaling.

Pixel Crawler remains a reference for modular organization, consistent character/prop scale, terrain transitions, animation coverage and clean pixels. Its 16×16 grid and approximately 16×30 visible body are facts about that pack, not requirements for Hollow Hearth. Do not copy its designs or redistribute its raw assets without verified rights. Keep Copperfern as the main-region identity and allow future regional variation under the shared style contract.

The owner's visual preference is recorded; this does not convert generated sheets into seamless tiles, validate animations or waive the playable benchmark before mass production.
