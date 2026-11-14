extends TestCase
## Scene flow through the real Main scene: tavern <-> forest by walking through doors.

var main: Main


func before_each() -> void:
	main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await wait_frames(3)
	main.start_new_game()
	await wait_frames(2)


func after_each() -> void:
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	main.queue_free()
	await wait_frames(2)


func _wait_for_world(world_id: StringName, max_frames: int) -> bool:
	for i in max_frames:
		if main.current_world != null and main.current_world.world_id == world_id and not main.is_traveling():
			return true
		await get_tree().physics_frame
	return false


func test_new_game_starts_inside_the_tavern() -> void:
	assert_eq(main.current_world.world_id, &"tavern")
	assert_true(main.player.is_inside_tree())
	assert_eq(GameState.location, &"tavern")


func test_walking_out_of_the_tavern_door_enters_the_forest() -> void:
	main.player.global_position = main.current_world.get_spawn_position(&"entrance")
	Input.action_press(&"move_down")
	var arrived := await _wait_for_world(&"forest", 240)
	Input.action_release(&"move_down")
	assert_true(arrived, "reached the forest")
	assert_eq(GameState.location, &"forest")
	var door_spawn := main.current_world.get_spawn_position(&"tavern_door")
	assert_true(main.player.global_position.distance_to(door_spawn) < 24.0, "appears outside the tavern door")


func test_walking_into_the_tavern_door_returns_inside() -> void:
	GameState.request_travel(&"forest", &"tavern_door")
	assert_true(await _wait_for_world(&"forest", 240), "reached the forest")
	Input.action_press(&"move_up")
	var arrived := await _wait_for_world(&"tavern", 240)
	Input.action_release(&"move_up")
	assert_true(arrived, "walked back into the tavern")
	assert_eq(GameState.location, &"tavern")
	var entrance := main.current_world.get_spawn_position(&"entrance")
	assert_true(main.player.global_position.distance_to(entrance) < 24.0, "appears just inside the door")


func test_player_cannot_move_during_the_transition() -> void:
	GameState.request_travel(&"forest", &"tavern_door")
	await wait_frames(1)
	assert_true(main.is_traveling())
	assert_false(main.player.input_enabled)
	assert_true(await _wait_for_world(&"forest", 240))
	assert_true(main.player.input_enabled)
