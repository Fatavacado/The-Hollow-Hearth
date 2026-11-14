class_name MapGrid
extends RefCounted
## A rectangular grid of single-character cells parsed from an ASCII map file.
## Lines starting with ';' are comments. Short rows are padded with `fill`.

var size := Vector2i.ZERO
var fill := "#"
var _rows: PackedStringArray = []


static func from_text(text: String, fill_char: String = "#") -> MapGrid:
	var grid := MapGrid.new()
	grid.fill = fill_char
	var width := 0
	for raw_line in text.split("\n"):
		var line := raw_line.trim_suffix("\r")
		if line.is_empty() or line.begins_with(";"):
			continue
		grid._rows.append(line)
		width = maxi(width, line.length())
	for i in grid._rows.size():
		grid._rows[i] = grid._rows[i].rpad(width, fill_char)
	grid.size = Vector2i(width, grid._rows.size())
	return grid


static func from_file(path: String, fill_char: String = "#") -> MapGrid:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("MapGrid: could not read map file '%s'" % path)
	return from_text(text, fill_char)


func at(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= size.x or cell.y >= size.y:
		return fill
	return _rows[cell.y][cell.x]


func find(character: String) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in size.y:
		for x in size.x:
			if _rows[y][x] == character:
				cells.append(Vector2i(x, y))
	return cells
