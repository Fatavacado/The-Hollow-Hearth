extends TestCase
## ASCII map parsing (MapGrid).


func test_rows_become_cells_addressed_by_column_and_row() -> void:
	var grid := MapGrid.from_text("ab\ncd\n")
	assert_eq(grid.size, Vector2i(2, 2))
	assert_eq(grid.at(Vector2i(1, 0)), "b")
	assert_eq(grid.at(Vector2i(0, 1)), "c")


func test_windows_line_endings_do_not_leak_into_cells() -> void:
	var grid := MapGrid.from_text("ab\r\ncd\r\n")
	assert_eq(grid.size, Vector2i(2, 2))
	assert_eq(grid.at(Vector2i(1, 0)), "b")


func test_comment_lines_are_ignored() -> void:
	var grid := MapGrid.from_text("; legend\nab\n;another\ncd")
	assert_eq(grid.size, Vector2i(2, 2))
	assert_eq(grid.at(Vector2i(0, 0)), "a")


func test_short_rows_are_padded_with_fill() -> void:
	var grid := MapGrid.from_text("abc\nd", "#")
	assert_eq(grid.size, Vector2i(3, 2))
	assert_eq(grid.at(Vector2i(2, 1)), "#")


func test_out_of_bounds_reads_return_fill() -> void:
	var grid := MapGrid.from_text("a", "#")
	assert_eq(grid.at(Vector2i(-1, 0)), "#")
	assert_eq(grid.at(Vector2i(0, 3)), "#")


func test_find_lists_matching_cells_in_reading_order() -> void:
	var grid := MapGrid.from_text("x.x\n.x.")
	assert_eq(grid.find("x"), [Vector2i(0, 0), Vector2i(2, 0), Vector2i(1, 1)])


func test_shipped_maps_are_rectangular() -> void:
	for path in ["res://data/maps/forest.txt", "res://data/maps/tavern.txt"]:
		var text := FileAccess.get_file_as_string(path)
		var widths := {}
		for line in text.split("\n"):
			var row := line.strip_edges(false, true)
			if row.is_empty() or row.begins_with(";"):
				continue
			widths[row.length()] = true
		assert_eq(widths.size(), 1, "%s rows must share one width, got %s" % [path, widths.keys()])
