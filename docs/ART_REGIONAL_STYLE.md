# Shared art language and regional identities

## Approved starting-region palette and lighting

The owner approved the brighter Copperfern revision. Use fresh spring greens with golden leaf highlights, light sandy/ochre paths, clear turquoise water, warm ivory plaster and honey-colored timber/floorboards. Keep teal roofs/shutters, cheerful terracotta/russet fabrics and small copper/brass accents. Match the current `docs/art-direction/copperfern-approved-top-down-reference.png`; earlier muted/dark studies are secondary references and must not override its daylight values.

Preserve crisp pixel edges, dark selective outlines, character/prop separation and readable contact shadows. Darkness belongs in localized canopy/occlusion shadows and later intentionally mysterious areas, not as a starting-region color wash. The tavern is bright with ambient/window daylight and localized hearth warmth; avoid both dark sepia and a blanket orange tint. Do not simply raise exposure or saturation until materials lose contrast. Stardew Valley is a cheerful daytime mood reference only; create original palette ramps and artwork, without copying its sprites or designs.

Keep the approved high top-down camera and shared regional style contract. This is visual palette approval, not a locked indexed palette, exact swatch list, runtime lighting configuration or production-assets validation. Future regions retain room for intentional atmospheric contrast.

## Current approved visual reference

The owner selected the **original Copperfern art with a high top-down RPG camera** and authorized publication to main for future developers. Read [the reference guide](ART_REFERENCE.md) and inspect `docs/art-direction/copperfern-approved-top-down-reference.png` before drawing or integrating art. This current camera/scene reference supersedes the lower, frontal environment illustrations. Preserve the original character's identity while fitting it to the higher camera and coherent actor/room scale. Earlier numerical profiles are candidates, not locked production geometry. Pixel Crawler informed camera/construction research only; use original art, not its asset pack as the game's default dependency.


Earlier decision: retain original Copperfern identity; the later high top-down reference above controls camera and scene scale. The tiny comparison remains an archived experiment.

## Decision and game-plan alignment

On 2026-11-14 the owner selected **Copperfern Guild for the main region**, after viewing the three-direction board. This supersedes the earlier Hearthglass recommendation. Scope: starting forest, main-region buildings and the home tavern. It does not approve every generated pixel or a final character design. The title is a visual working label, not new lore.

Read GAME_VISION.md, GAME_DESIGN_DOCUMENT.md, WORLD_EXPLORATION.md, PLAYER_PROGRESSION.md, GAMEPLAY_LOOP.md, TAVERN_MANAGEMENT.md and VERTICAL_SLICE.md. The plan connects exploration, ingredients, cooking, voluntary tavern service and upgrades. Later regions introduce distinct ingredients, traversal opportunities and guest requests. Art must make those discoveries legible and make returning home feel familiar. It must not invent progression gates, compulsory schedules, combat or new systems.

Current slice remains one forest, one tavern, five ingredients, three recipes, two supernatural guest archetypes and one upgrade. Regional planning is a framework for later expansion, not a commitment to build additional regions now.

## Shared across the game

- Non-isometric top-down three-quarter perspective, rectangular terrain and consistent visible top/front planes.
- One validated pixel-density standard, actor/door/furniture scale, foot-anchor convention and camera treatment. Candidate 32×32 tiles, 48×64 frames and 640×360 viewport remain provisional, with 480×270 still an alternative from the bible.
- Compatible anatomy and four-direction animation construction. A traveling actor retains the same body and equipment design in every region; do not redraw the player in a different style per biome.
- Deliberate clusters, consistent edge/outline treatment, readable value groups and a common approach to light/shadow ramps. Regional color changes cannot obscure feet or interaction targets.
- Stable meanings for gathering feedback, cooking completion, orders, interaction markers and UI. Regional ornament may vary, but accessibility and semantic cues remain recognizable.
- Foot-level collisions, consistent occlusion/Y-sorting, readable paths and a common export/metadata/provenance workflow.

## Main region: Copperfern Guild

**Shape and materials:** sturdy practical silhouettes; stepped fern/conifer masses; horizontal timber braces; squared shelves and broad cooking counters; copper kettles and selective brass fittings. Warm wood and fabric balance metal. Avoid turning every building into a factory.

**Candidate color anchors:** ink #293B45, spruce #3E6861, teal #5C9D91, russet #AE6549, brass #D3A158, cream #F1DBB1, sky #9DC9C8, moss #829357. These are test swatches, not final palette approval. Share material ramps between forest signage, carried equipment and tavern furniture, with sunny greens outdoors and localized hearth warmth indoors.

**Main-region traveler study:** compact broad torso, teal tunic, rust apron, broad boots and brass clasp. This is a starting silhouette brief, not a required uniform for the whole cast. Redesign the board's generic face/hair into an original, distinctive character before production approval.

**Readable forest:** clear return route, quiet walking surfaces and five distinguishable ingredient silhouettes within the slice content cap. Use contextual leaves, growth patterns and placement to make ingredients feel local; do not add ingredient types to satisfy decoration.

**Welcoming tavern:** clearly separate stove, serving area, seating and circulation. Cooking props and carrying poses should support existing interactions. Two supernatural guests need different silhouettes and personalities; coal-spirit and mushroom-scholar sketches are candidates, not new approved mechanics or mandatory species.

**Mood range:** sunny, rainy, twilight and mysterious variants remain Copperfern. Preserve warm home recognition without making every outdoor scene amber, misty or dark.

## What may differ in future regions

| Regional lever | May vary | Must remain compatible |
|---|---|---|
| Ecology | canopy shapes, terrain motifs, local flora and ingredient presentation | common texel density, scale and gathering readability |
| Built culture | construction materials, roof/door trim, local furniture ornament | perspective, usable door/table scale and interaction clearance |
| Atmosphere | regional hue families, weather accents, light temperature | readable values, stable actor identity and accessible cues |
| Guests | clothing, species silhouettes, local possessions and gestures | shared rendering/animation language, feet/origins and order readability |
| Discovery | visual framing of existing traversal opportunities and new ingredients | gameplay plan, clear affordances and consistent feedback semantics |

Meadows, rivers, ruins, caves and stranger places are possibilities in the plan, not approved named regions, a map order or promised scope. Do not allocate Hearthglass Orchard or Moonmilk Folk automatically. A future region can use a new proposal, or selectively revisit an unused concept after review.

## Regional brief template

```text
Region ID / approval state / gameplay-plan reference:
Role in exploration → ingredients → cooking → guests loop:
Mood and contrast with main region:
Three original shape motifs:
Local materials, ecology and architecture:
Palette ramps and shared UI/interaction colors:
Known player / door / tree / counter scale checks:
Existing traversal and ingredient affordances to communicate:
Shared rules inherited unchanged:
New reusable art modules vs genuinely bespoke work:
Provenance and source/reference review:
One native-scale scene comparison against Copperfern:
Owner review / technical benchmark results:
```

Develop only one bounded regional study at a time. Compare the same traveling player in the home region and candidate region; it must look like one game. A direction decision precedes a playable art benchmark; that benchmark precedes a reusable small kit and batch production. The next main-region milestone is one corrected four-direction player plus forest and tavern in the actual verified slice, not a complete world asset library.
