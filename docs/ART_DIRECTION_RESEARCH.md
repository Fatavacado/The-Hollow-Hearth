# Art direction research

Research date: 2026-11-14. Decision update: owner selected Copperfern Guild for the main region on 2026-11-14; see ART_REGIONAL_STYLE.md. Original comparative findings remain below.

## Scope and evidence

Read GAME_VISION.md, GAME_DESIGN_DOCUMENT.md, ART_BIBLE.md, VERTICAL_SLICE.md and CLAUDE.md. Preserve their non-isometric top-down three-quarter view, rectangular grid, four-direction movement, bright nature, welcoming hospitality and occasional mystery. Do not change gameplay. ART_BIBLE.md remains authoritative; proposed numerical specifications below are experiments.

Checked local and remote branches before creating `feat/art-direction-research`. Local `work` and remote `main` point at `2c77198a430ae02004c42d22e61afeb8945ec1c7`. No project.godot or playable slice exists in this checkout. Installed Godot is 4.6.3, not the user-reported 4.7.2. An unpushed slice elsewhere cannot be inspected or integrated here. No changes to gameplay, settings or production assets are part of this task.

### Research limits

Direct requests to the official game sites, itch.io, Aseprite FAQ, PixelLab, Lospec and hosted Godot docs returned proxy 403. Their links below are source destinations for follow-up, not claims of live image inspection. The visual observations are qualitative analysis based on prior knowledge of these games; no screenshot board, exact sprite measurement, animation frame count, current price or license permission was established from those blocked pages. Do not treat these references as approved reference images. Ashbound Wayfarer source art is absent and has not been invented.

GitHub project documentation and raw source documents for Aseprite, LibreSprite, Pixelorama and Godot were retrieved and read. The generated original concept board is separate from commercial reference research. A full reference-image review remains outstanding before production approval.

## Reference analysis: borrow principles, never designs

| Reference / source | Character and motion | Environments, palette and scale | Readability, cost and application |
|---|---|---|---|
| [Pixel Crawler — Anokolisa](https://anokolisa.itch.io/pixel-crawler) | Compact fantasy silhouettes; modular sprite systems are useful to study. Exact pack dimensions and animation coverage unverified. | A cohesive tile vocabulary can unify props and actors; do not assume this pack fits our provisional scale. | Useful production-system reference, not required final assets. Confirm exact edition, license and export rights before acquisition. No pack downloaded. |
| [Eastward](https://eastwardgame.com/) | Expressive acting and silhouette contrast; bespoke motion is costly. | Dense lived-in scenes, strong material separation and environmental storytelling. | Adapt focal hierarchy and meaningful prop groupings. Do not match its clutter density everywhere; hand-authoring every frame/background is beyond the slice budget. |
| [Moonlighter](https://www.moonlighterthegame.com/) | Clear action silhouettes and compact readable bodies. | Useful relationship between shop circulation, counters and top-down actors; warm/cool material grouping. | Study walkable space and actor/prop hierarchy. Reuse our own modular furniture grammar, not its shop layout or hero. |
| [Children of Morta](https://childrenofmorta.com/) | Dramatic silhouettes and motion; extensive bespoke animation implies high cost. | Layered depth, rich light and contrast, atmospheric supernatural spaces. | Borrow restrained depth cues and occasional dramatic accents. Constant darkness and heavy particles would conflict with our sunny, readable world. |
| [Stardew Valley](https://www.stardewvalley.net/) | Four-direction routines and recognizable accessories support everyday activities. | Reusable terrain, distinct seasonal/material ramps, straightforward relationships among doors, furniture and people. | Study economy of reusable assets and legible interaction areas; avoid copying head/body ratios, faces, buildings or signature crop/prop designs. |
| [Sea of Stars](https://seaofstarsgame.co/) — additional contextual reference | Expressive staged characters and action clarity. | Lush nature and time-of-day atmosphere provide useful comparison. | Treat high-detail lighting and environment animation as expensive selective accents, not a solo-developer baseline. Site not fetched in this session. |

These observations do not imply a game's exact technical pipeline or license. All commercial art is inspiration only, with no reuse permission established. There is no tracing, recoloring, extraction or redistribution of reference game art.

## Synthesis for Hollow Hearth

Use large designed pixel clusters rather than random per-pixel texture. Three value groups should communicate floor/path, upright furniture and actors before decorative marks are added. Keep feet visible, path edges calm and action targets distinct through shape plus value, not color alone. Render rectangular floor planes with visible top faces and vertical front faces; avoid diamond grids or oblique camera rotation.

Propose 32×32 terrain, 48×64 actor frames and a 640×360 comparison viewport, consistent with but not approved by ART_BIBLE.md. Frame size is a container: target approximately 28–34×44–50 visible actor pixels. Test the alternative 480×270 viewport before locking dimensions. Preserve one authored texel per game pixel; only integer display scaling. Environment detail is not permission to change texel size.

Start with one body rig, four directional walks, a shared material palette, one terrain family and modular tavern pieces. Reuse construction rules and animation timing, not identical silhouettes across every guest. Reserve bespoke animation for focal moments. Licensed terrain remains an option under the bible but requires compatibility and provenance review, not blind mixing.

## Sources actually retrieved

- [Aseprite EULA](https://github.com/aseprite/aseprite/blob/main/EULA.txt): proprietary software license; no right to redistribute the editor established.
- [LibreSprite README](https://github.com/LibreSprite/LibreSprite): free/open-source sprite editor; README states GPL v2.
- [Pixelorama README](https://github.com/Orama-Interactive/Pixelorama): layers, animation and pixel-art tooling; README states MIT.
- [Godot TileSet documentation source](https://github.com/godotengine/godot-docs/blob/master/tutorials/2d/using_tilesets.rst): TileMapLayer, atlas setup, physics layers and terrain peering bits. Master documentation is not proof of compatibility with an unavailable 4.7.2 runtime.

See ART_STYLE_EXPLORATIONS.md for three proposals and the owner-selected main-region direction; ART_PRODUCTION_PIPELINE.md for tools and gates; ASSET_PROVENANCE.md for the rights ledger.

## Subsequent evidence: owner-uploaded pack

The owner later uploaded the free Pixel Crawler exterior pack. Direct inspection now supersedes the earlier inability to inspect this particular reference. See [pack review](PIXEL_CRAWLER_REFERENCE_REVIEW.md) for measured grids, sprite bounds, action coverage, actual visual review and included license terms. Other blocked game-reference sources remain unverified.
