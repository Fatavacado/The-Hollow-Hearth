extends Node
## Visual benchmark capture. Runs the real game with the real renderer, poses a fixed set of shots
## and saves native-resolution PNGs for review. Needs a window/GPU (not --headless):
##
##   godot --path . res://tests/visual/capture_benchmark.tscn -- --out=C:/tmp/shots [--size=480x270]

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _out := ""
var main: Main


func _ready() -> void:
	_out = _arg("--out=", OS.get_user_data_dir().path_join("benchmark"))
	DirAccess.make_dir_recursive_absolute(_out)
	var size := _arg("--size=", "")
	if not size.is_empty():
		var parts := size.split("x")
		get_window().content_scale_size = Vector2i(int(parts[0]), int(parts[1]))
	main = MAIN_SCENE.instantiate()
	add_child(main)
	await _frames(20)
	await _shot("01_tavern_arrival_banner")
	await _frames(170)
	await _shot("02_tavern_interior")
	await _walk_strip("03_walk_cycle_down", &"move_down", 8)

	await _travel(&"forest", &"tavern_door")
	await _frames(170)
	await _shot("04_forest_tavern_entrance")
	await _pose(Vector2(22.5 * 32, 16 * 32), "05_forest_crossroads")
	await _pose(Vector2(37 * 32, 16 * 32), "06_forest_pond_hollow")
	await _pose(Vector2(8 * 32, 16 * 32), "07_forest_west_grove")
	await _pose(Vector2(32.5 * 32, 27.6 * 32), "08_forest_hidden_passage")
	await _pose(Vector2(39 * 32, 27 * 32), "09_forest_hidden_glade")
	await _pose(Vector2(30.5 * 32, 12.4 * 32), "10_forest_behind_tree_occlusion")
	print("benchmark shots written to ", _out)
	get_tree().quit()


func _travel(world_id: StringName, spawn_id: StringName) -> void:
	GameState.request_travel(world_id, spawn_id)
	while main.is_traveling() or main.current_world.world_id != world_id:
		await get_tree().process_frame


func _pose(at: Vector2, shot_name: String) -> void:
	main.player.global_position = at
	main.player.facing = Vector2.DOWN
	await get_tree().create_timer(0.4).timeout  # let occlusion fades settle
	await _shot(shot_name)


func _walk_strip(shot_name: String, action: StringName, count: int) -> void:
	# Crops around the player in every frame and lays the crops side by side.
	var cell := Vector2i(64, 80)
	var strip := Image.create(cell.x * count, cell.y, false, Image.FORMAT_RGBA8)
	Input.action_press(action)
	for i in count:
		await _frames(4)
		var frame := await _grab()
		var screen_pos := Vector2i(main.player.get_global_transform_with_canvas().origin)
		strip.blit_rect(frame, Rect2i(screen_pos + Vector2i(-32, -72), cell), Vector2i(i * cell.x, 0))
	Input.action_release(action)
	strip.save_png(_out.path_join(shot_name + ".png"))


func _shot(shot_name: String) -> void:
	var image := await _grab()
	image.save_png(_out.path_join(shot_name + ".png"))


func _grab() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func _arg(prefix: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return fallback
