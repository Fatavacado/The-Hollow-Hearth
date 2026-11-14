extends World
## The Whisperwood: a compact forest with the tavern on its northern edge.
## Map legend lives at the top of data/maps/forest.txt.

const TERRAIN_TEXTURE := preload("res://assets/art/tiles/forest_terrain.png")
const DECOR_TEXTURE := preload("res://assets/art/tiles/forest_decor.png")
const PROP_SCENE := preload("res://scenes/props/prop.tscn")
const TAVERN_EXTERIOR := preload("res://scenes/world/forest/tavern_exterior.tscn")

const TERRAIN_BY_CHAR := {"=": DualGrid.PATH, "~": DualGrid.WATER, "#": DualGrid.CANOPY}
const BLOCKING_CHARS := ["~", "#"]
## char -> [texture, foot_row, blocker size, horizontal jitter in px]
const PROPS := {
	"T": [preload("res://assets/art/props/oak_tree_a.png"), 76, Vector2(16, 8), 5],
	"Y": [preload("res://assets/art/props/oak_tree_b.png"), 76, Vector2(16, 8), 5],
	"P": [preload("res://assets/art/props/pine_tree.png"), 86, Vector2(12, 8), 4],
	"b": [preload("res://assets/art/props/bush.png"), 26, Vector2(26, 10), 2],
	"r": [preload("res://assets/art/props/rock.png"), 19, Vector2(20, 8), 3],
	"s": [preload("res://assets/art/props/stump.png"), 20, Vector2(20, 8), 3],
}
## Props tall enough to hide the player; they fade while the player is behind them.
const TALL_PROPS := ["T", "Y", "P"]
const GATHER_NODE_SCENE := preload("res://scenes/world/forest/gather_node.tscn")
const REGROW_SECONDS := 120.0
## char -> [item, sprite base name, max yield per harvest, foot_row, blocker size]
const GATHER_NODES := {
	"g": [preload("res://data/items/glowcap.tres"), "glowcap", 2, 25, Vector2.ZERO],
	"u": [preload("res://data/items/moonberry.tres"), "moonberry", 3, 26, Vector2(26, 10)],
	"f": [preload("res://data/items/fernleaf.tres"), "fernleaf", 2, 27, Vector2.ZERO],
	"v": [preload("res://data/items/sweetroot.tres"), "sweetroot", 2, 22, Vector2.ZERO],
	"h": [preload("res://data/items/honeycomb.tres"), "honeycomb", 2, 27, Vector2(40, 10)],
}
const DECOR_PERCENT := 16
const DECOR_TILE_COUNT := 8

@onready var decor: TileMapLayer = $Decor


func _build() -> void:
	_paint_ground()
	_paint_decor()
	_place_props()


func _blocked_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for c in BLOCKING_CHARS:
		cells.append_array(grid.find(c))
	return cells


func _terrain(cell: Vector2i) -> int:
	return TERRAIN_BY_CHAR.get(grid.at(cell), DualGrid.GRASS)


func _paint_ground() -> void:
	ground.tile_set = atlas_tileset(TERRAIN_TEXTURE)
	ground.position = -Vector2.ONE * CELL / 2.0  # dual grid: display tiles sit on cell corners
	for y in grid.size.y + 1:
		for x in grid.size.x + 1:
			var coords := DualGrid.atlas_coords(
					_terrain(Vector2i(x - 1, y - 1)), _terrain(Vector2i(x, y - 1)),
					_terrain(Vector2i(x - 1, y)), _terrain(Vector2i(x, y)),
					cell_hash(Vector2i(x, y)))
			ground.set_cell(Vector2i(x, y), 0, coords)


func _paint_decor() -> void:
	decor.tile_set = atlas_tileset(DECOR_TEXTURE)
	for cell in grid.find("."):
		var h := cell_hash(cell)
		if h % 100 < DECOR_PERCENT:
			decor.set_cell(cell, 0, Vector2i((h / 100) % DECOR_TILE_COUNT, 0))


func _place_props() -> void:
	for character: String in PROPS:
		var spec: Array = PROPS[character]
		for cell in grid.find(character):
			var prop: Prop = PROP_SCENE.instantiate()
			prop.texture = spec[0]
			prop.foot_row = spec[1]
			prop.blocker_size = spec[2]
			var h := cell_hash(cell)
			var jitter: int = spec[3]
			prop.position = cell_foot(cell) + Vector2((h % (jitter * 2 + 1)) - jitter, -(h / 7) % 3)
			prop.flip_h = (h / 3) % 2 == 0
			prop.fade_when_behind = character in TALL_PROPS
			actors.add_child(prop)
	for cell in grid.find("H"):
		var tavern := TAVERN_EXTERIOR.instantiate()
		tavern.position = cell_foot(cell)
		actors.add_child(tavern)
	_place_gather_nodes()


func _place_gather_nodes() -> void:
	for character: String in GATHER_NODES:
		var spec: Array = GATHER_NODES[character]
		for cell in grid.find(character):
			var node: GatherNode = GATHER_NODE_SCENE.instantiate()
			node.node_id = StringName("forest:%d,%d" % [cell.x, cell.y])
			node.item = spec[0]
			node.full_texture = load("res://assets/art/nodes/%s_full.png" % spec[1])
			node.empty_texture = load("res://assets/art/nodes/%s_empty.png" % spec[1])
			node.max_yield = spec[2]
			node.foot_row = spec[3]
			node.blocker_size = spec[4]
			node.regrow_seconds = REGROW_SECONDS
			node.texture = node.full_texture
			node.position = cell_foot(cell) + Vector2(0, -4)
			actors.add_child(node)
