extends TestCase
## Dual-grid terrain tile selection. Atlas layout is documented in tools/art/gen_world.py:
## row 0 path, row 1 water, row 2 canopy transitions (column = corner mask TL=1 TR=2 BL=4 BR=8),
## row 3 pure variants (0-3 grass, 4-7 path, 8-11 water, 12-15 canopy).

const G := DualGrid.GRASS
const P := DualGrid.PATH
const W := DualGrid.WATER
const K := DualGrid.CANOPY


func test_single_path_corner_selects_its_mask_column() -> void:
	assert_eq(DualGrid.atlas_coords(P, G, G, G, 0), Vector2i(1, 0))
	assert_eq(DualGrid.atlas_coords(G, G, G, P, 0), Vector2i(8, 0))


func test_two_path_corners_combine_bits() -> void:
	assert_eq(DualGrid.atlas_coords(G, P, G, P, 0), Vector2i(10, 0))


func test_water_and_canopy_use_their_own_rows() -> void:
	assert_eq(DualGrid.atlas_coords(W, W, G, G, 0), Vector2i(3, 1))
	assert_eq(DualGrid.atlas_coords(G, G, K, K, 0), Vector2i(12, 2))


func test_uniform_cells_use_pure_variants_chosen_by_seed() -> void:
	assert_eq(DualGrid.atlas_coords(G, G, G, G, 2), Vector2i(2, 3))
	assert_eq(DualGrid.atlas_coords(P, P, P, P, 1), Vector2i(5, 3))
	assert_eq(DualGrid.atlas_coords(W, W, W, W, 7), Vector2i(11, 3))
	assert_eq(DualGrid.atlas_coords(K, K, K, K, 4), Vector2i(12, 3))


func test_highest_priority_terrain_wins_where_three_meet() -> void:
	# canopy outranks water outranks path; lower terrains are drawn as grass in that tile
	assert_eq(DualGrid.atlas_coords(K, P, G, G, 0), Vector2i(1, 2))
	assert_eq(DualGrid.atlas_coords(P, W, G, W, 0), Vector2i(10, 1))
