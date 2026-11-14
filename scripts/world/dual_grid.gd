class_name DualGrid
extends RefCounted
## Chooses terrain atlas tiles for a dual-grid layout: each display tile sits on the corner shared
## by four map cells and blends their terrains. Atlas layout: see tools/art/gen_world.py.

enum { GRASS, PATH, WATER, CANOPY }

## Transition atlas row per terrain drawn over grass.
const TRANSITION_ROW := {PATH: 0, WATER: 1, CANOPY: 2}
const PURE_ROW := 3
const PURE_FIRST_COLUMN := {GRASS: 0, PATH: 4, WATER: 8, CANOPY: 12}
const VARIANTS := 4
## Higher wins when more than one non-grass terrain meets in one display tile.
const PRIORITY := [CANOPY, WATER, PATH]


## Corner terrains are top-left, top-right, bottom-left, bottom-right. `variant_seed` picks among
## the pure variants so large areas do not repeat one tile.
static func atlas_coords(tl: int, tr: int, bl: int, br: int, variant_seed: int) -> Vector2i:
	if tl == tr and tr == bl and bl == br:
		return Vector2i(PURE_FIRST_COLUMN[tl] + posmod(variant_seed, VARIANTS), PURE_ROW)
	var corners := [tl, tr, bl, br]
	for terrain in PRIORITY:
		if terrain in corners:
			var mask := 0
			for i in 4:
				if corners[i] == terrain:
					mask |= 1 << i
			return Vector2i(mask, TRANSITION_ROW[terrain])
	# Only grass remains, which the uniform branch already handled.
	return Vector2i(PURE_FIRST_COLUMN[GRASS], PURE_ROW)
