---
name: hollow-hearth-pixel-art
description: Create consistent original Copperfern pixel art with the approved high top-down RPG camera; design, review, and integrate Hollow Hearth artwork using the game's art bible, approval gates, provenance records, and native-scale Godot validation. Use for character sheets, terrain, props, guests, effects, and art consistency reviews.
---

# Hollow Hearth pixel-art production

Read `docs/ART_REFERENCE.md` and inspect `docs/art-direction/copperfern-approved-top-down-reference.png` first. Then read `GAME_VISION.md`, `docs/ART_BIBLE.md`, `docs/ART_STYLE_EXPLORATIONS.md`, `docs/ART_REGIONAL_STYLE.md`, `docs/ART_PRODUCTION_PIPELINE.md`, and `docs/ASSET_PROVENANCE.md` from the repository root. Before integration also read `CLAUDE.md` and `docs/VERTICAL_SLICE.md`. These are ordinary repository files, not assumed plugin resources. Resolve paths against the actual checkout, not the current terminal directory.

## Authority and current state

The art bible controls approved intent: rich HD pixel art, top-down / three-quarter, rectangular tiles, non-isometric, bright nature and inviting taverns with occasional mystery. Preserve gameplay and existing approved assets. The owner selected **Copperfern Guild for the main region** on 2026-11-14, superseding the earlier Hearthglass recommendation. Apply practical compact silhouettes, stepped forest masses, horizontal timber, teal/russet cloth and restrained copper/brass accents to the starting forest and home tavern. This is a visual label, not an added gameplay faction. Future regions may differ under `docs/ART_REGIONAL_STYLE.md`; do not automatically apply the main-region material palette everywhere or assign unused concepts to future regions. Candidate 32×32 terrain, 48×64 frames and 640×360 viewport remain provisional. Locate the actual approved board and approval record; Ashbound Wayfarer is an unavailable named benchmark until its original approved work is supplied, never a design to invent or copy.

No mass production before explicit direction approval and a coherent playable benchmark. No purchases, subscriptions or paid API calls without permission. Never copy/trace commercial sprites, use raw reference packs without rights, or assume generated output is production-ready.

## Active visual baseline

The latest owner-approved target is ORIGINAL Copperfern pixel art under a HIGH TOP-DOWN RPG camera, as shown in `docs/art-direction/copperfern-approved-top-down-reference.png`. Broad visible ground/floor, overhead roofs/tree canopies, dominant furniture tops and shallow vertical faces are required. Keep the original character's teal/russet wardrobe, hair and satchel identity but adjust its projection and actor/room scale to this camera. Earlier frontal/diorama environment illustrations are secondary material references, not the gameplay-camera target. Do not automatically shrink to the tiny experiment or lock the earlier larger sprite scale; choose measured native geometry through a coherent scene benchmark. Pixel Crawler is a camera/construction reference, not an approved asset dependency. Do not copy its sprites or layouts.

## Begin each task

1. Inspect Git branch/status, user changes, asset conventions and the actual Godot project. Do not overwrite another agent's work or migrate project settings. Use a dedicated branch for new research unless instructed otherwise. The owner explicitly authorized publishing the current reference package to main; future main updates require task authorization. Use existing isolated checkout; no new worktree unless requested.
2. Read approval state and relevant neighboring source assets. If direction is unapproved, produce only a bounded exploration and label it accordingly.
3. Verify available tools now. In the research environment Godot 4.6.3, Python/Pillow, ImageMagick and FFmpeg were available; Aseprite and LibreSprite were absent from PATH and PixelLab was not connected. Pixelorama 1.2.4 was subsequently installed outside the checkout; PNG round-trip passed, but startup reported shader/signal errors and graphical editing remains unverified. See pipeline for path and limits. User reports a Godot 4.7.2 slice; do not claim access or version compatibility without checking it. Never invent tool commands or capabilities.
4. Write the asset brief and provenance record before creation. Follow the templates in `docs/ART_PRODUCTION_PIPELINE.md`; choose region, shared style revision, regional palette revision, native size, foot anchor, actions, directions, neighbors, rights and acceptance evidence.

## Production sequence

Follow the detailed numbered workflow and inspection commands in `docs/ART_PRODUCTION_PIPELINE.md`. Apply these asset-specific rules:

- **Characters and silhouettes:** develop three original black silhouettes; test at 1× on grass, floor and dark backgrounds. Establish head/body/feet ratios and facing before texture detail. Preserve apron, tool and carrying readability.
- **Four-direction sheets:** independently resolve south/west/east/north volumes and asymmetric equipment. Candidate walk format: six 48×64 columns, four rows in that order, 288×256 PNG, anchor `(24,58)`, 8 fps as a test. Never let these defaults override an approved schema. Keep idle/actions explicit and metadata synchronized.
- **Terrain and seamless tiles:** draw interior/edges/inner and outer corners for the actual Godot connectivity mode. Test 3×3 and 8×8 patches; inspect every transition, motif repetition, palette relationship and walkable-ground clarity. Noise does not equal detail.
- **Trees, vegetation, buildings and interiors:** establish player/door/trunk/furniture scale first. Separate ground anchors from canopy/roof occluders; use rectangular footprints and consistent visible face depth. Cluster foliage deliberately and keep interactions unobscured.
- **Tavern furniture, stations and props:** use a shared seat/table/counter height study. Distinguish station roles and states by silhouette and value as well as color. Keep carried dishes, hands and approach spaces visible; separate steam/glow layers.
- **Supernatural guests and creatures:** derive appearance from personality and hospitality role, then a unique supernatural motif. Preserve facing, feet, order bubble and readable transparency. Supernatural does not require horror.
- **Effects:** author anticipation/event/fade, frame durations, emission socket, layer and footprint. Start small; gathering chips, steam and magic should clarify completion without hiding ingredients, orders or player position. Review flashing and contrast.
- **Animation and alignment:** retain fixed frame canvas and foot anchor; use onion skin, alpha bounds and contact overlays. Check first/last loop, volume, directional identity, held-prop sockets, cancel transitions and foot sliding at measured gameplay speed. No trimming without offset metadata.
- **Palette and density:** use approved named material ramps. Inspect grayscale and color-vision simulations; keep foreground values distinct, ground quiet and outlines selective. Maintain 1:1 source pixels and integer nearest-neighbor previews. Remove generated fringe/blur manually.
- **Export:** preserve editable source and exact native RGBA PNG. Name `{subject}_{action}_{variant}_vNNN.png`; pair with metadata specifying dimensions, row/direction/action order, frame durations, anchor, palette and provenance ID. Validate divisibility, nonempty frames, bounds and transparency. Labeled review sheets stay separate from runtime sheets.
- **Godot integration:** use a separately authorized integration task and the slice's verified engine. Inspect import policy; configure nearest filtering/lossless art consistently without changing globals casually. Map explicit `SpriteFrames` actions and regions. Keep actor origin at feet and collision on the footprint; inspect Y-sort configuration and wall/canopy occlusion in the real hierarchy. Do not auto-migrate TileMap systems.
- **Quality and consistency:** inspect in game at native resolution and integer scale, with player, forest and tavern together. Walk all directions around doors, counters, canopies and guests. Test collisions, carried dishes, ingredient affordances, order UI, day/interior/twilight states and animation speed. Headless import does not prove visual quality.
- **Licenses and attribution:** log creator, original URL, license evidence/date, commercial/modification/redistribution rights, attribution, tool/model and generation date, modifications, output paths and reviewer. Inspiration is not permission. Quarantine unknown rights and retain original design evidence.

## Review gates and reporting

Use pipeline gates G0–G4: rights/brief → direction approval → playable benchmark → reusable small kit → reviewed batch. The benchmark requires one four-direction player, compact forest and tavern scene flow with real engine inspection. Do not begin a full cast or terrain library before this passes.

Return the exact files changed, source/tool provenance, tests actually run, visual evidence actually inspected, approval state and remaining defects. Distinguish concept rendering, technically valid sprites, engine-imported sprites and approved gameplay art. Never claim a generated illustration is a seamless tileset or aligned animation based on appearance alone. If an expected tool or slice is unavailable, deliver reproducible specs and report the limitation instead of fabricating execution.

For Codex, use this repository skill in `.agents/skills`. For Claude Code, read and follow this `SKILL.md` explicitly when requested or referenced from project instructions; do not claim `.agents/skills` is automatically discovered by every client. No unsupported hook, plugin, paid integration or command is required.

## Original identity and secondary references

After viewing the tiny-size comparison, the owner chose to keep the **original Copperfern art first**. This supersedes the proposed switch/comparison to Pixel Crawler's small visible-character scale as the next production baseline. Preserve the original character's expressive curly-hair silhouette, teal rolled sleeves, cream undershirt, russet apron, satchel and sturdy boots, together with the detailed Copperfern forest/tavern material language.

Primary camera and scene-scale reference: `docs/art-direction/copperfern-approved-top-down-reference.png`. Use these secondary repository-root references for appearance and material studies:

- `docs/art-direction/copperfern-player-study-01.png`: original character appearance and wardrobe reference.
- `docs/art-direction/sprite-prototypes/copperfern_player_idle_south_v001.png`: original larger 48×64 frame prototype for runtime-scale comparison.
- `docs/art-direction/copperfern-environment-study-01.png`: forest/exterior and tavern material/composition reference.
- `docs/art-direction/copperfern-environment-assets-study-01.png`: environment asset vocabulary; requires native redraw and tile validation.

The tiny `copperfern_player_tiny_*` sprites and 16×16-grid proposal are archived experiments, **not the active style or production target**. Do not shrink or redesign new art to match them, reopen the tiny-scale comparison automatically, or let it override the selected original visual identity. Earlier 32×32 terrain, 48×64 frames and 640×360 viewport are retained as a candidate profile only; final visible character size, frame padding, grid and viewport must jointly match the approved high camera and pass Godot validation. Do not force a large frontal character into an overhead map. Preserve detail through deliberate native pixel construction, not smooth illustration downscaling.

Pixel Crawler remains a reference for modular organization, consistent character/prop scale, terrain transitions, animation coverage and clean pixels. Its 16×16 grid and approximately 16×30 visible body are facts about that pack, not requirements for Hollow Hearth. Do not copy its designs or redistribute its raw assets without verified rights. Keep Copperfern as the main-region identity and allow future regional variation under the shared style contract.

The owner's visual preference is recorded; this does not convert generated sheets into seamless tiles, validate animations or waive the playable benchmark before mass production.
