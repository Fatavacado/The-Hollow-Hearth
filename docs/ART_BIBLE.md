# Art Bible — Initial Reference Specification

## Current approved visual reference

The owner selected the **original Copperfern art with a high top-down RPG camera** and authorized publication to main for future developers. Read [the reference guide](ART_REFERENCE.md) and inspect `docs/art-direction/copperfern-approved-top-down-reference.png` before drawing or integrating art. This current camera/scene reference supersedes the lower, frontal environment illustrations. Preserve the original character's identity while fitting it to the higher camera and coherent actor/room scale. Earlier numerical profiles are candidates, not locked production geometry. Pixel Crawler informed camera/construction research only; use original art, not its asset pack as the game's default dependency.


## Identity
Rich, expressive HD pixel art for a cozy fantasy world with supernatural wonder and occasional mystery. Beautiful **bright** environments are as important as night scenes. Avoid making every biome creepy.

## Perspective and camera
Top-down three-quarter gameplay perspective, rectangular tiles, no diamond-grid isometric. Character and prop proportions must agree with terrain and buildings. Test a native 480×270 or 640×360 viewport, and provisional 32×32 terrain / ~48×64 characters; **none are approved until tested in Godot**.

## Reference roles (inspiration only)
- Previously approved **Ashbound Wayfarer**: character-art quality benchmark; locate original approved work before using, do not invent or copy design.
- **Eastward**: environmental richness and density, not its assets.
- **Moonlighter**: readable top-down interiors and scale.
- **Children of Morta**: atmospheric depth and lighting.
- **Dave the Diver**: gameplay rhythm, not visual copying.

Actual reference images must be collected, source-credited and reviewed before treating them as approved. These names are not licenses to copy their art.

## Production rules
Consistent pixel density, deliberate palette, stable foot anchors, 4-direction animation, clean transparent sprites, seamless terrain edges, clear foreground/background layers, nearest-neighbor rendering, no accidental blur, and tested Y-sorting/occlusion.

## Asset sourcing
Prefer cohesive licensed tilesets for reusable terrain, then customize carefully. GPT image generation is suitable for concept art and references, but output is not automatically a seamless tileset or aligned animation sheet. PixelLab or comparable sprite tools may help when actually accessible. Track creator, URL, license, attribution, modification rights and usage per asset. Never buy assets or incur API fees without approval.

## Visual benchmark gate
One playable four-direction character, a small detailed forest, and a warm tavern entrance/interior in the same Godot scene flow. Verify at native gameplay scale before mass production.

## Still to decide
Palette swatches, approved reference image board, exact tile/frame dimensions, character animation schema, UI style and lighting implementation.

## Owner-selected main-region direction — 2026-11-14

**Copperfern Guild** is the selected visual direction for the main region: the starting forest, its local structures and the home tavern. Use compact practical silhouettes, stepped fern/conifer clusters, warm horizontal timber, spruce/teal, russet fabric and restrained copper/brass accents. Preserve bright nature, cozy hospitality and personable supernatural guests. “Guild” is a proposal label, not an approved lore faction or new mechanic.

See [ART_REGIONAL_STYLE.md](ART_REGIONAL_STYLE.md) for the shared visual contract and future-region variation, and [ART_STYLE_EXPLORATIONS.md](ART_STYLE_EXPLORATIONS.md) for the selected proposal. Future regions may introduce different materials, plants, architecture and mood while retaining common perspective, pixel density, actor scale, animation language and readable interaction cues. Their content remains outside the initial slice.

This records the owner's explicit direction selection. Exact swatches, tile/frame sizes, UI, character designs and generated concept pixels remain candidates until benchmark validation; earlier provisional technical decisions are unchanged.

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
