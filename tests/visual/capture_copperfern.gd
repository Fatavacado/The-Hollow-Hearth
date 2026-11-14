extends Node
## Captures the Copperfern art benchmark from the real renderer (needs a window, not --headless):
##   godot --path . res://tests/visual/capture_copperfern.tscn -- --out=<dir>
## Writes native 640x360 screenshots and per-frame walk captures for animated previews.

const BENCH := preload("res://scenes/benchmark/copperfern/copperfern_benchmark.tscn")

var _out := ""
var bench: Node
var main: Main


func _ready() -> void:
	_out = _arg("--out=", OS.get_user_data_dir().path_join("copperfern"))
	DirAccess.make_dir_recursive_absolute(_out.path_join("walk"))
	bench = BENCH.instantiate()
	add_child(bench)
	main = bench.main
	await _wait(0.6)
	await _shot("cf_00_title")
	main.start_new_game()
	await _wait(0.8)
	await _shot("cf_01_tavern_arrival_banner")
	await _wait(2.6)
	# tavern: keeper beside the counter, then at the stove cooking, then the served dish
	await _pose(Vector2(232, 228), Vector2.UP, "cf_02_tavern_overview")
	await _pose(Vector2(372, 214), Vector2.UP, "cf_03_tavern_table_and_chairs")
	GameState.pantry.add(&"glowcap", 2)
	var stove: Node2D = main.current_world.get_node("Actors/Hearth")
	await _pose(stove.global_position + Vector2(0, 22), Vector2.UP, "cf_04_stove_prompt")
	main.player.try_interact()
	await _wait(0.2)
	main.cooking_panel.choose(&"glowcap_soup")
	await _wait(0.9)
	await _shot("cf_05_stove_cooking_steam")
	await _wait(1.6)
	main.cooking_panel.close()
	await _pose(Vector2(196, 228), Vector2.LEFT, "cf_06_dish_on_counter")
	await _walk_capture("tavern")
	# forest
	GameState.request_travel(&"forest", &"tavern_door")
	while main.is_traveling() or main.current_world.world_id != &"forest":
		await get_tree().process_frame
	await _wait(0.8)
	await _shot("cf_07_forest_arrival")
	await _wait(2.6)
	await _pose(Vector2(352, 236), Vector2.DOWN, "cf_08_forest_path")
	await _pose(Vector2(336, 140), Vector2.UP, "cf_09_glowcap_prompt")
	main.player.try_interact()
	await _wait(0.3)
	await _shot("cf_10_glowcap_gathered")
	await _pose(Vector2(3 * 32 + 16, 5 * 32 + 22), Vector2.UP, "cf_11_moonberry_prompt")
	main.player.try_interact()
	await _wait(0.3)
	await _shot("cf_12_moonberry_gathered")
	await _pose(Vector2(6 * 32 + 16, 5 * 32 + 20), Vector2.UP, "cf_13_behind_tree_fade")
	await _walk_capture("forest")
	print("copperfern captures written to ", _out)
	SaveService.delete_save()
	get_tree().quit()


func _pose(at: Vector2, facing: Vector2, shot_name: String) -> void:
	main.player.global_position = at
	main.player.facing = facing
	await _wait(0.45)
	await _shot(shot_name)


## Walks each direction for one second, saving a 64x80 crop around the player every frame.
func _walk_capture(place: String) -> void:
	var start := main.current_world.get_spawn_position(&"start" if place == "tavern" else &"tavern_door")
	start += Vector2(0, -60) if place == "forest" else Vector2(60, 40)
	for action: StringName in [&"move_down", &"move_left", &"move_right", &"move_up"]:
		main.player.global_position = start
		await _wait(0.2)
		Input.action_press(action)
		for i in 36:
			await RenderingServer.frame_post_draw
			var image := get_viewport().get_texture().get_image()
			var p := Vector2i(main.player.get_global_transform_with_canvas().origin)
			image.get_region(Rect2i(p + Vector2i(-32, -70), Vector2i(64, 80))).save_png(
					_out.path_join("walk/%s_%s_%02d.png" % [place, String(action).trim_prefix("move_"), i]))
		Input.action_release(action)


func _shot(shot_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(_out.path_join(shot_name + ".png"))


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _arg(prefix: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return fallback
