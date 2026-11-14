extends TestCase
## Merging blocked cells into few collision rectangles.


func test_horizontal_runs_merge_into_one_rect() -> void:
	var rects := CollisionRects.from_cells([Vector2i(0, 0), Vector2i(1, 0), Vector2i(3, 0)])
	assert_eq(rects, [Rect2i(0, 0, 2, 1), Rect2i(3, 0, 1, 1)])


func test_identical_runs_in_consecutive_rows_merge_vertically() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 3)]
	assert_eq(CollisionRects.from_cells(cells), [Rect2i(0, 0, 2, 2), Rect2i(0, 3, 1, 1)])


func test_cell_order_does_not_matter() -> void:
	var cells: Array[Vector2i] = [Vector2i(1, 1), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	assert_eq(CollisionRects.from_cells(cells), [Rect2i(0, 0, 2, 2)])


func test_every_blocked_cell_is_covered_exactly_once() -> void:
	var cells: Array[Vector2i] = []
	for y in 6:
		for x in 7:
			if (x * 3 + y * 5) % 4 != 0:
				cells.append(Vector2i(x, y))
	var covered := {}
	for r: Rect2i in CollisionRects.from_cells(cells):
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var c := Vector2i(x, y)
				assert_false(covered.has(c), "cell %s covered twice" % c)
				covered[c] = true
	assert_eq(covered.size(), cells.size())
	for c in cells:
		assert_true(covered.has(c), "cell %s not covered" % c)
