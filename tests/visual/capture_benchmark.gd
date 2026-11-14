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
	var scenario := _arg("--scenario=", "benchmark")
	if has_method("_scenario_" + scenario):
		await call("_scenario_" + scenario)
	else:
		push_error("unknown scenario " + scenario)
	print("shots written to ", _out)
	get_tree().quit()


func _scenario_benchmark() -> void:
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


func _scenario_gathering() -> void:
	await _travel(&"forest", &"tavern_door")
	await get_tree().create_timer(2.5).timeout  # banner gone
	var glowcap := _gather_node_at(Vector2i(34, 10))
	await _face(glowcap)
	await _shot("m2_01_prompt_at_glowcap")
	main.player.try_interact()
	await get_tree().create_timer(0.3).timeout
	await _shot("m2_02_gathered_toast_and_picked_node")
	main.hud.toggle_inventory()
	await _frames(3)
	await _shot("m2_03_inventory_panel_forest")
	main.hud.toggle_inventory()
	await _face(_gather_node_at(Vector2i(9, 16)))
	await _shot("m2_04_berry_grove")
	await _face(_gather_node_at(Vector2i(38, 25)))
	await _shot("m2_05_hidden_glade_honey")
	main.player.try_interact()
	await _travel(&"tavern", &"entrance")
	await get_tree().create_timer(2.5).timeout
	var pantry: Node2D = main.current_world.get_node("Actors/Pantry")
	await _face(pantry)
	await _shot("m2_06_prompt_at_pantry")
	main.player.try_interact()
	await get_tree().create_timer(0.3).timeout
	main.hud.toggle_inventory()
	await _frames(3)
	await _shot("m2_07_stored_and_inventory_tavern")


func _scenario_cooking() -> void:
	await get_tree().create_timer(2.5).timeout
	GameState.pantry.add(&"glowcap", 5)
	GameState.pantry.add(&"fernleaf", 2)
	GameState.satchel.add(&"moonberry", 2)
	GameState.satchel.add(&"sweetroot", 1)
	var hearth: Node2D = main.current_world.get_node("Actors/Hearth")
	main.player.global_position = hearth.global_position + Vector2(18, 22)
	main.player.facing = Vector2.UP
	await get_tree().create_timer(0.3).timeout
	main.player.try_interact()
	await get_tree().create_timer(0.3).timeout
	await _shot("m3_01_cooking_panel")
	main.cooking_panel.choose(&"glowcap_soup")
	await get_tree().create_timer(0.7).timeout
	await _shot("m3_02_cooking_in_progress")
	await get_tree().create_timer(1.2).timeout
	main.cooking_panel.choose(&"moonberry_tart")
	await get_tree().create_timer(2.0).timeout
	main.cooking_panel.choose(&"glowcap_soup")
	await get_tree().create_timer(1.8).timeout
	await _shot("m3_03_after_cooking_panel")
	main.cooking_panel.close()
	main.player.global_position = Vector2(150, 222)
	await get_tree().create_timer(0.4).timeout
	await _shot("m3_04_dishes_on_counter")


func _scenario_service() -> void:
	await get_tree().create_timer(2.5).timeout
	GameState.counter.add(&"glowcap_soup", 2)
	GameState.counter.add(&"moonberry_tart", 2)
	var service: TavernService = main.current_world.get_node("Service")
	service.first_arrival_delay = 0.5
	service.arrival_interval = Vector2(1.2, 1.2)
	service.rng.seed = 3
	var sign: Node2D = main.current_world.get_node("Actors/OpenSign")
	await _face(sign)
	main.player.try_interact()
	await get_tree().create_timer(0.4).timeout
	await _shot("m4_01_opened")
	await get_tree().create_timer(6.0).timeout
	await _shot("m4_02_guests_seated_with_orders")
	var waiting := service.guests().filter(func(g: Guest) -> bool: return g.is_waiting())
	if not waiting.is_empty():
		var guest: Guest = waiting[0]
		main.player.global_position = guest.global_position + Vector2(0, 16)
		main.player.facing = Vector2.UP
		await get_tree().create_timer(0.3).timeout
		await _shot("m4_03_serve_prompt")
		main.player.try_interact()
		await get_tree().create_timer(guest.data.eat_seconds + 0.3).timeout
		await _shot("m4_04_paid_coins_and_thanks")
	GameState.set_tavern_open(false)
	GameState.earn(60)
	await _face(main.current_world.get_node("UpgradeBoard"))
	main.player.try_interact()
	await get_tree().create_timer(0.3).timeout
	await _shot("m4_05_upgrade_board")
	main.upgrade_panel.buy(&"expanded_satchel")
	await get_tree().create_timer(0.3).timeout
	await _shot("m4_06_upgrade_bought")


func _gather_node_at(cell: Vector2i) -> GatherNode:
	var wanted := StringName("forest:%d,%d" % [cell.x, cell.y])
	for node in main.current_world.find_children("*", "", true, false):
		if node is GatherNode and node.node_id == wanted:
			return node
	push_error("no gather node at %s" % cell)
	return null


func _face(target: Node2D) -> void:
	main.player.global_position = target.global_position + Vector2(0, 14)
	main.player.facing = Vector2.UP
	await get_tree().create_timer(0.3).timeout


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
