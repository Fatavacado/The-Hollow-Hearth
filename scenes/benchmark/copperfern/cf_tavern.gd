extends World
## Copperfern art benchmark: daylight tavern room. Floor/walls from the map; furniture in the scene.

const TILES := preload("res://assets/art/benchmark/copperfern/tavern_tiles_v001.png")
const BLOCKING := ["L", "R", "U", "P", "W", "Q", "F"]
const TILE_BY_CHAR := {
	"S": Vector2i(5, 0), "s": Vector2i(6, 0), "m": Vector2i(7, 0),
	"U": Vector2i(0, 1), "P": Vector2i(1, 1), "W": Vector2i(2, 1), "Q": Vector2i(3, 1),
	"L": Vector2i(4, 1), "R": Vector2i(5, 1), "F": Vector2i(6, 1),
}


func _fill_char() -> String:
	return " "


func _build() -> void:
	ground.tile_set = atlas_tileset(TILES)
	for y in grid.size.y:
		for x in grid.size.x:
			var cell := Vector2i(x, y)
			var ch := grid.at(cell)
			var coords: Vector2i
			if TILE_BY_CHAR.has(ch):
				coords = TILE_BY_CHAR[ch]
			elif grid.at(cell + Vector2i.UP) in ["W", "Q"]:
				coords = Vector2i(4, 0)  # planks in the back wall's shadow
			else:
				coords = Vector2i(cell_hash(cell) % 4, 0)
			ground.set_cell(cell, 0, coords)


func _blocked_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for c in BLOCKING:
		cells.append_array(grid.find(c))
	return cells
