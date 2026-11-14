# Copperfern player — design study 01

Latest owner decision: retain the original Copperfern art and larger character treatment. The tiny 16×30 comparison is an archived experiment, not the active style. See the pixel-art skill and ART_BIBLE.md for current reference and scale rules. Exact production dimensions remain subject to Godot validation.

Status: original concept proposal, character approval pending. Main-region Copperfern direction is selected; this individual character is not yet approved. No gameplay, production sprite or engine settings change.

## Design brief

A practical traveler and tavern keeper who can gather, cook and serve in the same outfit. Identity should survive travel to future regions: local surroundings vary, while body proportions, wardrobe and pixel construction stay recognizable.

- Compact sturdy adult silhouette, roughly 4.5 heads tall, distinct head and visible elbow gaps.
- Proposed appearance: medium-brown skin, short espresso curls with an asymmetrical forelock, expressive restrained face. Appearance is a proposal, not established lore or a customization-system decision.
- Spruce-teal rolled sleeves, cream undershirt, short split russet work apron, charcoal trousers and broad brown ankle boots.
- Small square brass clasp and one stitched fern motif. Small ingredient satchel on the character's left hip, with a copper measuring spoon; keep physical side consistent across directions.
- No oversized backpack or headwear obscuring facing. Hands, carried bowl and feet need clear silhouettes.
- Upper-left key light and deliberate 3–4-value material ramps. Start from the Copperfern anchor palette in ART_REGIONAL_STYLE.md; skin/hair need their own compatible ramps.

## Requested concept views

One large three-quarter character, down/side/back studies, black silhouette and small gathering/serving poses. The gathering plant is a placeholder visual, not a sixth ingredient or new gameplay commitment. No name, lore faction, combat mechanic or mandatory demographic canon is established by this study.

## Production translation after design review

Treat the generated sheet as reference. Redraw at native scale rather than shrinking the illustration into a production sheet. Candidate visible body is approximately 34×46 pixels in a 48×64 frame, foot anchor (24,58); actual scale remains a benchmark decision. Draw all four directions independently, including a true opposite-side view for asymmetrical equipment. Use the pipeline's candidate six-frame walks and two-frame idles only after silhouette approval. Inspect the face and apron at 1×, and simplify any embroidery/tool pixels that turn into noise.

Validate alpha edges, fixed frame dimensions, foot contact, volume and satchel consistency. Compare against a door, counter and tree trunk in the actual slice. Check carried-bowl visibility, ordering UI, canopy occlusion and Y-sorting. No playable or import validation is claimed here; this checkout has no project.godot.

## Delivered concept and visual review

[Player study 01](copperfern-player-study-01.png), generated 2026-11-14 with the available image tool, no reference-image inputs. It presents the specified wardrobe, curls, three directional studies and gather/serve action studies. The large portrait and smaller views have different proportions; redraw a single consistent body before animation. Satchel placement in the back study appears on the opposite physical hip from the front study and must be corrected. The eyebrow nick and fern motif are portrait-level detail and may not survive native resolution. The palette labels are design guidance, not a measured indexed palette. Smooth/textured edges remain; this is not exact-pixel production art or a complete four-direction rig.
