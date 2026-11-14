extends TestCase
## Title screen, pause menu, autosave and continuing a saved game through the real Main scene.

var main: Main
var toasts: PackedStringArray = []


func before_each() -> void:
	SaveService.delete_save()
	toasts.clear()
	Feedback.toast_requested.connect(_record_toast)
	main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await wait_frames(3)


func after_each() -> void:
	Feedback.toast_requested.disconnect(_record_toast)
	get_tree().paused = false
	main.queue_free()
	SaveService.delete_save()
	await wait_frames(2)


func _record_toast(text: String, _icon: Texture2D) -> void:
	toasts.append(text)


func _press(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
	await wait_frames(2)


func _arrive(world_id: StringName) -> bool:
	for i in 300:
		if main.current_world.world_id == world_id and not main.is_traveling():
			return true
		await get_tree().physics_frame
	return false


func test_launch_shows_the_title_and_freezes_the_player() -> void:
	assert_true(main.title_screen.visible)
	assert_false(main.player.input_enabled)
	assert_false(main.title_screen.can_continue(), "nothing to continue without a save")


func test_new_game_from_the_title_starts_play_in_the_tavern() -> void:
	main.title_screen.choose(&"new_game")
	await wait_frames(2)
	assert_false(main.title_screen.visible)
	assert_true(main.player.input_enabled)
	assert_eq(main.current_world.world_id, &"tavern")


func test_arriving_somewhere_autosaves() -> void:
	main.title_screen.choose(&"new_game")
	GameState.request_travel(&"forest", &"tavern_door")
	assert_true(await _arrive(&"forest"))
	assert_true(SaveService.has_save())
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SaveService.save_path))
	assert_eq(saved["location"], "forest")


func test_escape_pauses_and_resumes() -> void:
	main.title_screen.choose(&"new_game")
	await wait_frames(2)
	await _press(&"pause")
	assert_true(main.pause_menu.visible)
	assert_true(get_tree().paused)
	await _press(&"pause")
	assert_false(main.pause_menu.visible)
	assert_false(get_tree().paused)


func test_escape_closes_an_open_panel_instead_of_pausing() -> void:
	main.title_screen.choose(&"new_game")
	Feedback.open_panel(&"cooking")
	await wait_frames(2)
	await _press(&"pause")
	assert_false(main.cooking_panel.visible)
	assert_false(main.pause_menu.visible)
	assert_false(get_tree().paused)


func test_saving_and_continuing_restores_progress_and_position() -> void:
	main.title_screen.choose(&"new_game")
	GameState.earn(33)
	GameState.pantry.add(&"sweetroot", 2)
	GameState.request_travel(&"forest", &"tavern_door")
	assert_true(await _arrive(&"forest"))
	var spot := Vector2(22.5 * 32, 15 * 32)
	main.player.global_position = spot
	await wait_physics_frames(2)
	await _press(&"pause")
	main.pause_menu.choose(&"save")
	assert_true(toasts[-1].to_lower().contains("saved"), toasts[-1])
	main.pause_menu.choose(&"quit_to_title")
	await wait_frames(2)
	assert_true(main.title_screen.visible)
	assert_false(get_tree().paused)
	GameState.new_game()  # simulate a fresh launch: memory no longer holds the session
	assert_true(main.title_screen.can_continue())
	main.title_screen.choose(&"continue")
	assert_true(await _arrive(&"forest"))
	assert_false(main.title_screen.visible)
	assert_eq(GameState.coins, 33)
	assert_eq(GameState.pantry.count(&"sweetroot"), 2)
	assert_true(main.player.global_position.distance_to(spot) < 2.0, "player back where they saved")


func test_continuing_a_damaged_save_reports_it_and_stays_on_the_title() -> void:
	var file := FileAccess.open(SaveService.save_path, FileAccess.WRITE)
	file.store_string("not a save")
	file.close()
	main.title_screen.refresh()
	assert_true(main.title_screen.can_continue())
	main.title_screen.choose(&"continue")
	await wait_frames(2)
	assert_true(main.title_screen.visible)
	assert_true(toasts[-1].to_lower().contains("damaged"), toasts[-1])
