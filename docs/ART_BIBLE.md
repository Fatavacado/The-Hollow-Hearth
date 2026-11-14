# Art Bible — Initial Reference Specification

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
