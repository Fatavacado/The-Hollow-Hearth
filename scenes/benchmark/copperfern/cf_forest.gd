extends World
## Copperfern art benchmark: a small sunny forest clearing built from the benchmark kit.
## Same World/DualGrid/GatherNode systems as the slice; only the art and layout differ.

const ART := "res://assets/art/benchmark/copperfern_v002/"  # PixelLab props (tools/art/copperfern_v002)
## v002 terrain: PixelLab Wang tiles, palette-corrected (tools/art/copperfern_v002).
const TERRAIN := preload("res://assets/art/benchmark/copperfern_v002/forest_terrain_v002.png")
const DECOR := preload("res://assets/art/benchmark/copperfern/forest_decor_v001.png")
const PROP_SCENE := preload("res://scenes/props/prop.tscn")
const GATHER_NODE_SCENE := preload("res://scenes/world/forest/gather_node.tscn")
const TERRAIN_BY_CHAR := {"=": DualGrid.PATH, "#": DualGrid.CANOPY}
const DECOR_PERCENT := 18
const DECOR_TILES := 6
## char -> [texture file, foot_row, blocker size, fades when the player is behind it]
const PROPS := {
	"T": ["tree_round_v002.png", 102, Vector2(16, 8), true],
	"b": ["bush_v002.png", 33, Vector2(28, 10), false],
}
## char -> [item, sprite base name, max yield, foot_row, blocker size]
const GATHER := {
	"g": [preload("res://data/items/glowcap.tres"), "glowcap", 2, 25, Vector2.ZERO],
	"u": [preload("res://data/items/moonberry.tres"), "moonberry", 3, 42, Vector2(30, 10)],
}

@onready var decor: TileMapLayer = $Decor


func _build() -> void:
	ground.tile_set = atlas_tileset(TERRAIN)
	ground.position = -Vector2.ONE * CELL / 2.0
	for y in grid.size.y + 1:
		for x in grid.size.x + 1:
			ground.set_cell(Vector2i(x, y), 0, DualGrid.atlas_coords(
					_terrain(Vector2i(x - 1, y - 1)), _terrain(Vector2i(x, y - 1)),
					_terrain(Vector2i(x - 1, y)), _terrain(Vector2i(x, y)), cell_hash(Vector2i(x, y))))
	decor.tile_set = atlas_tileset(DECOR)
	for cell in grid.find("."):
		var h := cell_hash(cell)
		if h % 100 < DECOR_PERCENT:
			decor.set_cell(cell, 0, Vector2i((h / 100) % DECOR_TILES, 0))
	for character: String in PROPS:
		var spec: Array = PROPS[character]
		for cell in grid.find(character):
			var prop: Prop = PROP_SCENE.instantiate()
			prop.texture = load(ART + spec[0])
			prop.foot_row = spec[1]
			prop.blocker_size = spec[2]
			prop.fade_when_behind = spec[3]
			prop.flip_h = cell_hash(cell) % 2 == 0
			prop.position = cell_foot(cell)
			actors.add_child(prop)
	for character: String in GATHER:
		var spec: Array = GATHER[character]
		for cell in grid.find(character):
			var node: GatherNode = GATHER_NODE_SCENE.instantiate()
			node.node_id = StringName("forest:%d,%d" % [cell.x, cell.y])
			node.item = spec[0]
			node.full_texture = load(ART + "%s_full_v002.png" % spec[1])
			node.empty_texture = load(ART + "%s_empty_v002.png" % spec[1])
			node.max_yield = spec[2]
			node.foot_row = spec[3]
			node.blocker_size = spec[4]
			node.texture = node.full_texture
			node.position = cell_foot(cell) + Vector2(0, -4)
			actors.add_child(node)


func _blocked_cells() -> Array[Vector2i]:
	return grid.find("#")


func _terrain(cell: Vector2i) -> int:
	return TERRAIN_BY_CHAR.get(grid.at(cell), DualGrid.GRASS)
