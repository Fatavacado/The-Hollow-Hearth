extends TestCase
## The Copperfern art benchmark entry scene, played through the real game flow and real input.

var bench: Node
var main: Main


func before_each() -> void:
	bench = (load("res://scenes/benchmark/copperfern/copperfern_benchmark.tscn") as PackedScene).instantiate()
	add_child(bench)
	await wait_frames(3)
	main = bench.main
	main.start_new_game()
	await wait_frames(2)


func after_each() -> void:
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	bench.queue_free()
	await wait_frames(2)


func _press(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
	await wait_frames(2)


func _walk_until_world(action: StringName, world_id: StringName) -> bool:
	Input.action_press(action)
	for i in 300:
		if main.current_world.world_id == world_id and not main.is_traveling():
			Input.action_release(action)
			return true
		await get_tree().physics_frame
	Input.action_release(action)
	return false


func test_benchmark_uses_its_own_worlds_and_save_file() -> void:
	assert_eq(main.current_world.scene_file_path, "res://scenes/benchmark/copperfern/cf_tavern.tscn")
	assert_ne(SaveService.save_path, SaveService.DEFAULT_PATH, "never touches the player's real save")


func test_player_wears_the_copperfern_sheet_with_six_frame_walk() -> void:
	assert_true(main.player.sprite.texture.resource_path.ends_with("player_runtime_v001.png"))
	assert_eq(main.player.sprite.hframes, 8)
	Input.action_press(&"move_right")
	var columns := {}
	for i in 40:
		await wait_physics_frames(1)
		columns[main.player.sprite.frame % 8] = true
	Input.action_release(&"move_right")
	assert_eq(main.player.sprite.frame / 8, 2, "east row")
	assert_true(columns.size() >= 5, "six-frame walk cycles: %s" % [columns.keys()])


func test_walk_out_gather_walk_back_and_cook_on_the_stove() -> void:
	main.player.global_position = main.current_world.get_spawn_position(&"entrance")
	assert_true(await _walk_until_world(&"move_down", &"forest"), "walked out to the clearing")
	var glowcap: GatherNode = null
	for node in main.current_world.find_children("*", "", true, false):
		if node is GatherNode and node.item.id == &"glowcap":
			glowcap = node
			break
	main.player.global_position = glowcap.global_position + Vector2(0, 16)
	main.player.facing = Vector2.UP
	await wait_physics_frames(3)
	await _press(&"interact")
	assert_eq(GameState.satchel.count(&"glowcap"), 2, "gathered with the interact action")
	main.player.global_position = main.current_world.get_spawn_position(&"tavern_door")
	assert_true(await _walk_until_world(&"move_down", &"tavern"), "walked back to the tavern")
	var stove: Node2D = main.current_world.get_node("Actors/Hearth")
	main.player.global_position = stove.global_position + Vector2(0, 20)
	main.player.facing = Vector2.UP
	await wait_physics_frames(3)
	await _press(&"interact")
	assert_true(main.cooking_panel.visible, "the stove opens the cooking panel")
	assert_true(main.cooking_panel.choose(&"glowcap_soup"), "benchmark pantry supplies the fernleaf")
	await wait_seconds(2.0)
	assert_eq(GameState.counter.count(&"glowcap_soup"), 1)
	assert_eq(main.current_world.get_node("Actors/Counter").shown_dish_count(), 1, "dish on the counter")
