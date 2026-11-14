class_name World
extends Node2D
## Base for explorable spaces. Terrain and terrain collision are built from an ASCII map when the
## scene loads; hand-placed nodes (furniture, doors, spawn points) live in the scene itself.
## Subclasses implement `_build()` and `_blocked_cells()`.

const CELL := 32

@export var world_id: StringName = &""
@export_file("*.txt") var map_path: String = ""
@export var display_name: String = ""

var grid: MapGrid

@onready var ground: TileMapLayer = $Ground
@onready var actors: Node2D = $Actors

static var _tileset_cache := {}


func _ready() -> void:
	grid = MapGrid.from_file(map_path, _fill_char())
	_build()
	_add_terrain_collision(_blocked_cells())
	_add_map_bounds()


## Character used for cells outside the map.
func _fill_char() -> String:
	return "#"


func _build() -> void:
	pass


func _blocked_cells() -> Array[Vector2i]:
	return []


func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL) + Vector2.ONE * (CELL / 2.0)


## Bottom-centre of a cell: where a prop standing on that cell puts its origin.
func cell_foot(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL + CELL / 2.0, (cell.y + 1) * CELL)


## Stable pseudo-random number per cell, for decoration variety without per-run changes.
func cell_hash(cell: Vector2i) -> int:
	var h := (cell.x * 73856093) ^ (cell.y * 19349663) ^ (hash(world_id) & 0xffff)
	return absi(h)


func get_bounds() -> Rect2i:
	return Rect2i(Vector2i.ZERO, grid.size * CELL)


## Camera limits: the map bounds, widened and centred when the map is smaller than the screen
## (which locks the camera for single-screen rooms).
func get_camera_limits() -> Rect2i:
	var bounds := get_bounds()
	var view := Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height"))
	var pos := bounds.position
	var size := bounds.size
	if size.x < view.x:
		pos.x -= (view.x - size.x) / 2
		size.x = view.x
	if size.y < view.y:
		pos.y -= (view.y - size.y) / 2
		size.y = view.y
	return Rect2i(pos, size)


func get_spawn_points() -> Array[SpawnPoint]:
	var found: Array[SpawnPoint] = []
	_collect(self, func(n: Node) -> bool: return n is SpawnPoint, found)
	return found


func get_doors() -> Array[DoorTrigger]:
	var found: Array[DoorTrigger] = []
	_collect(self, func(n: Node) -> bool: return n is DoorTrigger, found)
	return found


func get_spawn_position(spawn_id: StringName) -> Vector2:
	for spawn in get_spawn_points():
		if spawn.spawn_id == spawn_id:
			return spawn.global_position
	push_error("World '%s' has no spawn point '%s'" % [world_id, spawn_id])
	return Vector2(get_bounds().get_center())


func add_actor(node: Node2D) -> void:
	actors.add_child(node)


static func atlas_tileset(texture: Texture2D) -> TileSet:
	if _tileset_cache.has(texture):
		return _tileset_cache[texture]
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(CELL, CELL)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(CELL, CELL)
	for y in texture.get_height() / CELL:
		for x in texture.get_width() / CELL:
			source.create_tile(Vector2i(x, y))
	tileset.add_source(source, 0)
	_tileset_cache[texture] = tileset
	return tileset


func _add_terrain_collision(cells: Array[Vector2i]) -> void:
	var body := StaticBody2D.new()
	body.name = "TerrainCollision"
	body.collision_mask = 0
	for r in CollisionRects.from_cells(cells):
		_add_box(body, Rect2(Vector2(r.position * CELL), Vector2(r.size * CELL)))
	add_child(body)


func _add_map_bounds() -> void:
	var body := StaticBody2D.new()
	body.name = "MapBounds"
	body.collision_mask = 0
	var b := Rect2(get_bounds())
	_add_box(body, Rect2(b.position.x - CELL, b.position.y - CELL, CELL, b.size.y + CELL * 2))
	_add_box(body, Rect2(b.end.x, b.position.y - CELL, CELL, b.size.y + CELL * 2))
	_add_box(body, Rect2(b.position.x, b.position.y - CELL, b.size.x, CELL))
	_add_box(body, Rect2(b.position.x, b.end.y, b.size.x, CELL))
	add_child(body)


func _add_box(body: StaticBody2D, rect: Rect2) -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	body.add_child(shape)


func _collect(node: Node, predicate: Callable, out: Array) -> void:
	for child in node.get_children():
		if predicate.call(child):
			out.append(child)
		_collect(child, predicate, out)
