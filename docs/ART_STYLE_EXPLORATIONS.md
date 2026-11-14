# Three original visual identity proposals

## Current approved visual reference

The owner selected the **original Copperfern art with a high top-down RPG camera** and authorized publication to main for future developers. Read [the reference guide](ART_REFERENCE.md) and inspect `docs/art-direction/copperfern-approved-top-down-reference.png` before drawing or integrating art. This current camera/scene reference supersedes the lower, frontal environment illustrations. Preserve the original character's identity while fitting it to the higher camera and coherent actor/room scale. Earlier numerical profiles are candidates, not locked production geometry. Pixel Crawler informed camera/construction research only; use original art, not its asset pack as the game's default dependency.


Earlier decision: retain original Copperfern identity; the later high top-down reference above controls camera and scene scale. The tiny comparison remains an archived experiment.

Owner decision (2026-11-14): **Copperfern Guild is selected for the main region**, including the starting forest and home tavern. A and C remain exploratory alternatives, not assigned future regions. Approval covers visual direction, not exact sprites, dimensions, palette values or an engine-validated benchmark. They preserve ART_BIBLE.md's top-down three-quarter non-isometric perspective, rectangular grid and cozy/adventurous tone. None is a recolor of an existing game's assets. Names are working labels, not trademark clearances.

## Shared comparison contract

Compare at 640×360 native pixels, 32×32 terrain, 48×64 character frame, foot anchor (24,58), visible adult body roughly 28–34×44–50 px. These are provisional candidates, not changes to the project. All three use the same path width (96 px), door opening (48 px), table footprint (64×48 px), camera orientation and actor location. Draw three separate authored native-size panels per direction: character plate, sunny forest, warm tavern. No diagonal diamond-grid construction.

Each forest panel: central path, tree masses left/right, one gatherable left, tavern sign right, player centered. Each tavern panel: stove left, serving counter rear, table right, player centered, two guests. Character plate: down/right/up views and silhouette strip; final production requires left too. Retain clear routes before decoration. Same empty scene layout must be used for an eventual Godot A/B comparison.

## A — Hearthglass Orchard (alternative)

**Philosophy:** Hospitality made from orchard light, clay and repaired glass. Repeated branching window mullions, split cape hems and pear-shaped leaf masses connect traveler, forest and tavern through a common visual grammar.

**Character:** Rounded rectangular torso, readable boots, asymmetrical split apricot cook's cape, indigo trousers and small rectangular ingredient satchel. Avoid oversized hats hiding the head silhouette. Silhouette must still read without cape embroidery. Keep satchel on the correct body side in every direction; do not mirror asymmetrical equipment blindly.

**Environment/architecture:** Warm lime/clay plaster, rounded rectangular openings, copper branching window supports and horizontal timber bases. Trees have two or three pear-shaped canopy masses, with quiet interiors and selected lit leaf edges. Glass-like color clusters are foliage styling, not literal stained glass on every tree. Stove, kettle and countertop have distinct ceramic/metal/wood ramps.

**Palette/lighting proposal:** ink #30334B, indigo #48577D, jade #477B65, leaf #90AD64, cream #F4DEB4, apricot #EC9865, copper #B9674F, glass teal #73B9AF. These eight anchors seed 3–4 value steps per material, with a provisional shared 32-color budget excluding transparency. Warm upper-left daylight; cooler shadow shifts; small amber hearth accents. Don't tint the whole room orange or turn daytime forests dark. Check grayscale separation.

**Animation:** 4 walk directions × 6 frames, 8 fps starting point; 4 directions × 2 idle frames at 2 fps; balanced ground contacts, modest cape follow-through. No floor sliding or changing head size. A four-frame directional interact pose may follow approval. Mood comes from timing and eye/shoulder acting rather than expensive particle trails.

**Tavern/guests:** Branch-mullion window, apricot cloth runner and copper stove tie the room to the traveler. A porcelain kettle spirit expresses hospitality with a recognizable lid/handle silhouette; a willow guest uses a hanging leaf mantle with a visible body gap. Both remain distinguishable in silhouette and grayscale. Do not make all supernatural guests glowing translucent blobs.

**Difficulty:** Medium. Distinct canopy shapes and asymmetrical clothing need deliberate correction. Restrict glass detail to focal windows, sign and select leaves. Advantage: strongest shared identity and warm/magical balance. Drawback: excessive stained-glass patterning becomes visual noise and animation cost.

## B — Copperfern Guild (selected for main region)

**Philosophy:** A practical traveler's haven built by craftspeople; durable tools and forest growth share stepped, bracket-like shapes.

**Character:** Compact broad torso, square teal tunic, rust apron, broad boots and brass clasp. A visible elbow notch separates arms from body. Equipment silhouette is a low horizontal roll rather than A's split cape.

**Environment/architecture:** Layered angular fern and conifer masses, horizontal beams, stepped roof edges and copper pipework. Rectangular countertops, bracket-supported shelving, straight floorboards. Keep workshop motifs sparse so the tavern remains a home rather than a factory.

**Palette/lighting:** ink #293B45, spruce #3E6861, teal #5C9D91, russet #AE6549, brass #D3A158, cream #F1DBB1, sky #9DC9C8, moss #829357. Shared 32-color starting budget. Broad cool daylight and local warm copper highlights. Never use metallic highlight flicker on every surface.

**Scale/motion:** Shared 32×32 tiles, 48×64 frames; visible body nearer 34×44 px, low center of gravity. Six-frame walk with firmer heel placement and short apron lag; two-frame idles. Same 8/2 fps test rates as A, making comparison fair.

**Tavern/guests:** Stacked jars, square hanging sign, organized modular cooking stations. A coal sprite has a jagged dark body with a small warm face; mushroom scholar has a brim-like cap and book-shaped satchel. No reference-game mushroom sprite reuse.

**Difficulty:** Low–medium, relative to the other proposals. Modular woodwork and compact actors are economical. Advantage: best solo production efficiency and clear prop grammar. Drawback: can become generic workshop fantasy; needs bespoke shape motifs and forest warmth to remain memorable.

## C — Moonmilk Folk

**Philosophy:** Gentle folklore in birch clearings: airy daytime cream and sage, intimate plum shadows at night. Supernatural life feels domestic and curious.

**Character:** Slender cream wrap coat, plum scarf, narrow boots and seed-shaped satchel; tapered silhouette distinct from A/B. Avoid lace-like single-pixel clutter. Scarf gesture should not conceal hands or interaction objects.

**Environment/architecture:** Scalloped birch canopies, limewashed rounded rectangular walls, ink-blue timber, crescent ceramics and woven cloth. Rectangular floors remain clearly horizontal. Reserve moons for signs/tableware; do not place crescent motifs on every object.

**Palette/lighting:** ink #37354D, plum #855875, periwinkle #8B95BC, sage #829D86, pale leaf #BAC58B, milk #F2E9D1, amber #DFAD65, rose #C88F8D. Shared 32-color starting budget. Sunny forests retain crisp mid-value trunks; warm lamps occupy small areas. No full-screen lavender wash.

**Scale/motion:** Shared 32×32 tiles and 48×64 frames; narrower 28×50 px visible body. Six-frame walk with restrained coat swing, two-frame idle, same initial frame rates as A/B. Scarf motion is secondary; feet must remain readable.

**Tavern/guests:** Cream crockery, plum woven runner and ink-blue shelves. Linen ghost with stitched face and a moth guest with folded wings/legible feet. Wings must not cover seats or change collision expectations.

**Difficulty:** Medium–high: pale actors need careful background separation; thin limbs/scarf demand alignment cleanup. Advantage: unusual gentle supernatural identity and elegant interiors. Drawback: weaker outdoor contrast and risk of overemphasizing night/ethereal softness.

## Original assessment and current decision

| Criterion (1 low, 5 high; design judgment, not measured playtest) | A | B | C |
|---|---:|---:|---:|
| Original shared shape grammar | 5 | 3 | 4 |
| Bright nature + inviting hospitality | 5 | 4 | 4 |
| Gameplay readability potential | 4 | 5 | 3 |
| Cohesion across actors/architecture | 5 | 4 | 4 |
| Solo production feasibility | 3 | 5 | 3 |

The initial research recommendation was A. The owner subsequently chose **B, Copperfern Guild, for the main region**. This decision supersedes that recommendation. Use the compact, practical traveler, layered angular forest masses, teal/russet/brass materials and welcoming timber tavern as the main-region direction. The name is an art-direction label, not a new in-world guild or gameplay faction.

Future regions are part of the long-term game plan, not additions to the current vertical slice. They can develop distinct regional materials, vegetation, architecture and mood within a common pixel-art language. Do not assign A or C to a region without a separate creative decision. See [regional style contract](ART_REGIONAL_STYLE.md).

Next validation is one hand-corrected four-direction actor + compact forest + tavern benchmark in the actual project. Exact colors, frame geometry and animation remain provisional until tested. Direction selection does not claim that a production rig or playable benchmark passes.

## Generated comparison and review

See [comparison board](art-direction/concept-comparison.png). Original AI-assisted concept board, not approved production assets. It contains all nine requested subjects with broadly comparable layout. It is **not** an exact 640×360 raster test: labels and panel composition are illustrative, actor sizes vary, no complete animation sheets exist, some edges use subpixel/smoothed detail and floor/prop projection is not perfectly consistent. The printed claim of consistent gameplay scale is aspirational and not verified. No native-pixel or engine benchmark is claimed.

A succeeds in connecting canopy color clusters, apron/cape and tavern window. Its foliage is too patterned for production without simplification. B has the clearest structural modules but its hero face is too similar to A's; redesign facial/head silhouette before proceeding. C separates wardrobe and mood well, but pale trunk/coat values risk merging. All rows need collision-aware routing, native-resolution redraw, four-direction registration and measured actor/door/table scale before any integration.
