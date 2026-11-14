# Copperfern environment sprites and tiles — visual study

Status: visual asset vocabulary, not a verified runtime atlas. The environment scene concepts show the desired finished atmosphere; this study separates terrain, plants, construction pieces and furniture so their production roles are clear.

| Family | Runtime form | Validation needed |
|---|---|---|
| Grass, dirt, cobble, timber, hearth stone | Candidate 32×32 terrain cells | Actual native raster, edge repetition, material value and texel density |
| Path boundaries | Terrain edge/corner/junction cells | Every required terrain-peering combination; inner corners and seams |
| Trees and tall plants | Separate trunk/ground anchor and canopy sprites | Foot-level collision, canopy occlusion, Y-sort and actor visibility |
| Door, window, wall, roof | Modular building sprites | Shared dimensions, opening clearance, top/front plane consistency and roof handling |
| Table, chair, counter, stove, shelving | Individual props or modular segments | Player-scale comparison, seat/station approach, carried-item visibility and collision footprint |

A tree or counter may occupy multiple terrain cells; it is not squeezed into a 32×32 tile. The player remains at one common scale across rooms and regions. Background floor is quiet, interactables distinctive, and foreground canopies do not hide essential paths. Nearest-neighbor source pixels and integer display scales are required after native redraw.

The selected main region uses Copperfern materials. Later region kits may change plants, terrain, architecture and lighting while inheriting the shared style contract. This study does not supply those unapproved future regions.

Before runtime use, author/export exact-size cells and separate props, complete all terrain transitions, remove unwanted alpha fringe, test repeated patches, configure actual Godot atlas/terrain data and validate collisions/sorting in the available slice. An AI-generated sheet does not establish seamlessness, extraction coordinates, production dimensions or engine readiness.

## Delivered sheet review

[Asset study 01](copperfern-environment-assets-study-01.png) shows six terrain surfaces, four path-transition examples, woodland vegetation, building pieces and tavern furniture on transparency. Materials match the Copperfern direction. The generated swatches have irregular outer edges and do not yet form seamless square runtime cells; trees also use different detail densities from terrain. Path transitions are incomplete for an actual terrain set. Roof/wall modules need measured matching joins; props need collision/scale validation. Treat this as a visual vocabulary sheet, not a directly importable atlas or complete region kit.
