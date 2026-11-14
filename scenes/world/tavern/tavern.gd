extends World
## The Hollow Hearth tavern interior. Floor and walls come from data/maps/tavern.txt;
## furniture, doors and spawn points are placed in tavern.tscn.

const TILES_TEXTURE := preload("res://assets/art/tiles/tavern_tiles.png")
const FLOOR_VARIANTS := 4
const BLOCKING_CHARS := ["|", "+", "W", "I", "w", "_"]


func _fill_char() -> String:
	return " "


func _build() -> void:
	ground.tile_set = atlas_tileset(TILES_TEXTURE)
	for y in grid.size.y:
		for x in grid.size.x:
			var cell := Vector2i(x, y)
			var coords := _tile_for(cell)
			if coords.x >= 0:
				ground.set_cell(cell, 0, coords)


func _blocked_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for c in BLOCKING_CHARS:
		cells.append_array(grid.find(c))
	return cells


func _tile_for(cell: Vector2i) -> Vector2i:
	match grid.at(cell):
		".", "D":
			if grid.at(cell + Vector2i.UP) == "w":
				return Vector2i(4, 0)  # floor in the back wall's shadow
			return Vector2i(cell_hash(cell) % FLOOR_VARIANTS, 0)
		"m":
			return Vector2i(5, 0)
		"+":
			return Vector2i(0, 1)
		"W":
			return Vector2i(1, 1)
		"I":
			return Vector2i(2, 1)
		"w":
			return Vector2i(3, 1)
		"|":
			return Vector2i(4, 1) if cell.x == 0 else Vector2i(5, 1)
		"_":
			return Vector2i(6, 1)
	return Vector2i(-1, -1)
