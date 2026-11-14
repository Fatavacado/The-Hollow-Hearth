extends TestCase
## World scenes built from data/maps/*.txt: terrain, collision, spawns, doors and camera bounds.

const WORLD_SCENES := {
	&"tavern": "res://scenes/world/tavern/tavern.tscn",
	&"forest": "res://scenes/world/forest/forest.tscn",
}


func _spawn_world(world_id: StringName) -> World:
	var world: World = (load(WORLD_SCENES[world_id]) as PackedScene).instantiate()
	add_child(world)
	await wait_physics_frames(2)
	return world


func _solid_at(world: World, point: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = 1
	return not world.get_world_2d().direct_space_state.intersect_point(query).is_empty()


func test_forest_terrain_covers_every_display_cell() -> void:
	var world := await _spawn_world(&"forest")
	assert_eq(world.ground.get_used_cells().size(), (world.grid.size.x + 1) * (world.grid.size.y + 1))
	world.queue_free()


func test_forest_canopy_and_water_block_but_paths_do_not() -> void:
	var world := await _spawn_world(&"forest")
	assert_true(_solid_at(world, world.cell_center(Vector2i(0, 0))), "canopy corner")
	assert_true(_solid_at(world, world.cell_center(Vector2i(39, 12))), "pond water")
	assert_false(_solid_at(world, world.cell_center(Vector2i(22, 11))), "path below the tavern door")
	world.queue_free()


func test_tavern_walls_block_and_floor_is_open() -> void:
	var world := await _spawn_world(&"tavern")
	assert_true(_solid_at(world, world.cell_center(Vector2i(0, 5))), "side wall")
	assert_true(_solid_at(world, world.cell_center(Vector2i(5, 2))), "back wall")
	assert_true(_solid_at(world, world.cell_center(Vector2i(3, 10))), "front wall")
	assert_false(_solid_at(world, world.cell_center(Vector2i(9, 10))), "doorway")
	assert_false(_solid_at(world, world.cell_center(Vector2i(8, 7))), "floor")
	world.queue_free()


func test_every_spawn_point_stands_on_open_ground() -> void:
	for world_id in WORLD_SCENES:
		var world := await _spawn_world(world_id)
		var spawns := world.get_spawn_points()
		assert_true(spawns.size() > 0, "%s has spawn points" % world_id)
		for spawn in spawns:
			assert_false(_solid_at(world, spawn.global_position + Vector2(0, -4)),
					"%s spawn '%s' is inside collision" % [world_id, spawn.spawn_id])
		world.queue_free()
		await wait_frames(1)


func test_every_door_leads_to_an_existing_spawn() -> void:
	var spawns_by_world := {}
	var targets: Array[Array] = []
	for world_id in WORLD_SCENES:
		var world := await _spawn_world(world_id)
		spawns_by_world[world_id] = world.get_spawn_points().map(func(s: SpawnPoint) -> StringName: return s.spawn_id)
		for door in world.get_doors():
			targets.append([door.target_world, door.target_spawn])
		world.queue_free()
		await wait_frames(1)
	assert_true(targets.size() >= 2, "both worlds have a door")
	for target in targets:
		assert_true(spawns_by_world.has(target[0]), "door targets unknown world %s" % target[0])
		assert_true(target[1] in spawns_by_world.get(target[0], []),
				"door targets missing spawn %s/%s" % target)


func test_tavern_camera_is_locked_to_one_screen() -> void:
	var world := await _spawn_world(&"tavern")
	var limits := world.get_camera_limits()
	assert_eq(limits.size, Vector2i(640, 360))
	assert_true(limits.encloses(Rect2i(Vector2i.ZERO, world.grid.size * World.CELL)), "room fully visible")
	world.queue_free()


func test_forest_camera_limits_match_map_bounds() -> void:
	var world := await _spawn_world(&"forest")
	assert_eq(world.get_camera_limits(), Rect2i(Vector2i.ZERO, world.grid.size * World.CELL))
	world.queue_free()
