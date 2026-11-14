class_name CollisionRects
extends RefCounted
## Merges blocked grid cells into a small set of non-overlapping rectangles (in cell units):
## horizontal runs first, then identical runs on consecutive rows.


static func from_cells(cells: Array) -> Array[Rect2i]:
	var by_row := {}
	for c: Vector2i in cells:
		if not by_row.has(c.y):
			by_row[c.y] = []
		by_row[c.y].append(c.x)

	# Horizontal runs per row.
	var runs: Array[Rect2i] = []
	var rows := by_row.keys()
	rows.sort()
	for y: int in rows:
		var xs: Array = by_row[y]
		xs.sort()
		var start: int = xs[0]
		var prev: int = xs[0]
		for i in range(1, xs.size() + 1):
			var x: int = xs[i] if i < xs.size() else prev + 2
			if x == prev:
				continue  # duplicate cell
			if x != prev + 1:
				runs.append(Rect2i(start, y, prev - start + 1, 1))
				start = x
			prev = x

	# Grow each run downwards over identical runs in the following rows.
	var open := {}  # Vector2i(x, width) -> index into merged
	var merged: Array[Rect2i] = []
	var last_row := -2
	for run in runs:
		if run.position.y != last_row:
			var still_open := {}
			for key: Vector2i in open:
				if merged[open[key]].end.y == run.position.y:
					still_open[key] = open[key]
			open = still_open
			last_row = run.position.y
		var key := Vector2i(run.position.x, run.size.x)
		if open.has(key):
			merged[open[key]].size.y += 1
		else:
			open[key] = merged.size()
			merged.append(run)
	return merged
