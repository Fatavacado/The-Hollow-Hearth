# Copperfern sprite prototype

Latest owner decision: retain the original Copperfern art and larger character treatment. The tiny 16×30 comparison is an archived experiment, not the active style. See the pixel-art skill and ART_BIBLE.md for current reference and scale rules. Exact production dimensions remain subject to Godot validation.

`copperfern_player_idle_south_v001.png`: 48×64 transparent RGBA PNG, single down-facing idle frame. Foot baseline y=57, proposed scene anchor (24,58). Preview is nearest-neighbor 8× and must not be used as the game texture.

Original image tool output `/workspace/generated_images/exec-52dc577f-eed8-43b6-819e-d951ebe95337.png`, generated using the original player design study as input. ImageMagick: alpha threshold 50%, trim, nearest-neighbor fit within 34×50, limited-color reduction, bottom-centered placement in 48×58 then transparent extent to 48×64. Corrected two eye pixels and one mouth pixel at native size for readability. Checked exact canvas size and binary alpha; inspected enlarged preview. This is a static sprite prototype, not a four-direction rig or completed animation. Scale/projection and facial clarity still need native-resolution comparison against the real game. No Godot import/playtest claimed because this checkout lacks the project.

Use nearest filtering, no automatic trimming, and place the actor origin at the foot anchor when evaluating in the actual slice. Reuse player-study provenance, plus this generation/export record. Individual sprite approval pending.

## Native tiny-size comparison

`copperfern_player_tiny_16x30_v001.png` is an original explicitly constructed 16×30 pixel sprite (visible bounds 13×30), 16 opaque colors plus transparency. `copperfern_player_tiny_idle_south_64x64_v001.png` places it at (24,18) in a 64×64 padded canvas, matching the inspected reference frame convention without copying its pixels. `copperfern_player_tiny_12x_preview.png` shows exact pixels enlarged 12× on cream. It is a separate native-pixel design experiment, not a downsample of Pixel Crawler or the generated illustration. The palette and row construction are retained in tiny_player_source.py; its output path currently targets this checkout. Hair mass, teal shirt, russet apron, two eye pixels, boots and satchel survive; embroidery, eyebrow nick and tiny utensils are omitted. This static front-facing test has no animation or engine validation.

A parallel generated simplified concept is retained outside Git at `/workspace/generated_images/exec-287ea689-842d-4e5f-a976-0cae9b6dd5cf.png`; it is a high-resolution illustration of coarse clusters, not the measured 16×30 file. Use the measured native sprite/12× preview when judging actual pixel count.
