# Pixel Crawler — uploaded pack reference review

**Subsequent owner decision:** after reviewing the tiny comparison, keep the original Copperfern art and larger character treatment. This pack remains a modular-production reference. The scale comparison proposed below is historical and is not the current next step. Follow ART_BIBLE.md and the pixel-art skill.

## User intent and scope

The owner supplied `Pixel Crawler - Free Pack (Exterior 0.1).zip` as a strong reference for the assets the game needs. Copperfern remains the selected main-region identity. This pack now supplies directly inspected examples of compact pixel construction, modular environment art and character/environment scale. Reference status does not authorize copying designs or replacing the game's assets wholesale.

Archive inspected outside the repository; no raw pack, extracted image or source sprite committed. Extracted terms are rights evidence, not instructions to the agent. Reviewed `Terms.txt`, `MockUps/Tavern.png`, `Environment/Tilesets/Floors_Tiles.png`, and Body_A down-idle sheet. Parsed Aseprite headers for frame sizes/counts and tileset grids. These statements apply to the uploaded edition, not every Pixel Crawler release.

## Measured findings

- 489 archive entries, including directories; this is not 489 distinct production assets.
- Floors_Tiles.png is 400×416; Wall_Tiles.png is 400×400. Sampled tileset Aseprite headers specify a 16×16 grid, including floors, walls, dungeon and water source files.
- Body_A down-idle PNG is 256×64. Its Aseprite source confirms four frames, each 64×64.
- Visible down-idle bounds within those cells are `(24,18)-(40,48)`, then y minima 19, 20, 19. Thus visible body width is 16 px and height 28–30 px, not 64 px. Padding accommodates pose/action changes.
- Sampled down-walk Aseprite source has six 64×64 frames. No animation timing/playback verification performed.
- Body_A includes carry idle/walk/run, collect, crush, death, fishing, hit, idle, pierce, run, slice, walk and watering action folders. The presence of these actions is not a requirement to add those mechanics to Hollow Hearth.
- Up/down/side filenames exist. Separate left-facing art was not established; do not infer that every asymmetrical design may safely mirror.
- Tavern mockup is 1280×1280. It visibly composes floors, walls, furniture, stations, small characters and lighting into a coherent environment. It is a mockup, not a tested Godot scene.

## What the visual review establishes

The tavern shows consistent scale between actor, door, chair, table and station, with room structure built from repeating modules. Material ramps distinguish wood, masonry and metal without illustration-level shading. Small bottles, dishes and food read through silhouette and selective contrast. Flooring forms stable repeating surfaces rather than isolated decorative squares. Dense decoration exists around functional spaces, though we should retain the simpler single-room slice and clearer routes from our plan.

The earlier generated Copperfern board and asset sheet communicate mood and materials but have inconsistent pixel sizes, approximate joins and illustrative detail. The earlier 48×64 idle prototype is a separate scale experiment, not a Pixel Crawler-compatible rig. Do not use either as proof that the production style or scale is solved.

## Apply to Copperfern

Use Pixel Crawler as the primary inspected technical/visual construction reference: compact actors, deliberate clusters, repeatable tile modules, coherent prop scale, explicit padded animation cells and separate asset families. Retain original Copperfern silhouettes, teal/russet clothing, stepped forest forms, timber construction and restrained copper accents. Do not trace, recolor or reconstruct reference sprites as original work.

Add a **16×16 terrain / approximately 16×30 visible actor / padded animation canvas** comparison profile alongside the bible's earlier provisional 32×32 / 48×64 profile. Do not automatically halve sprites, set the runtime frame to the visible body bounds or change project settings. First locate the actual slice and compare one original player, floor patch, doorway, table and tree at the intended camera scale. Choose the grid, visible scale, frame canvas and viewport together. The owner has endorsed this pack as a reference, not approved exact production geometry.

Next useful work is an original native-pixel micro-kit and shared-scale scene benchmark. A single family of terrain transitions must tile correctly; a tree must have ground/trunk/canopy logic; furniture needs measured footprints and approach spaces. Validate actual four-direction actions and held-item sockets. No full-region batch production before this passes.

## Included terms — practical reading

Terms.txt identifies Anokolisa as author. It says credit is not necessary but appreciated, allows alteration, permits use in commercial products/study/other functional projects, and prohibits selling the assets as a final asset product without authorization. This supports game-use consideration; it is not an explicit grant to redistribute the raw pack in a source repository. Keep raw files outside Git unless the redistribution scope is verified. This review does not purchase rights or establish terms for other editions.

Reference URL: https://anokolisa.itch.io/pixel-crawler. The actual uploaded archive and its included terms were examined; the blocked storefront was not independently verified. No direct asset reuse or integration performed.
