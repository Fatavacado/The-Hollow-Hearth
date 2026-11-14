extends "res://tests/visual/capture_benchmark.gd"
## Extends baseline capture utilities: same real worlds, coordinates, viewport and save isolation.
## Also usable unchanged on a8085de for a camera/composition matched baseline capture.

func _scenario_codex_v2() -> void:
	await get_tree().create_timer(4.2).timeout
	await _shot("01_tavern_interior")
	await _travel(&"forest", &"tavern_door")
	await get_tree().create_timer(4.2).timeout
	await _shot("02_forest_entrance")
	await _face(_gather_node_at(Vector2i(34,10)))
	await _shot("03_forest_gathering")
	main.hud.toggle_inventory()
	await _frames(3)
	await _shot("04_inventory_readability")
	main.hud.toggle_inventory()
	await _pose(Vector2(30.5 * 32,12.4 * 32),"05_tree_occlusion")
	await _travel(&"tavern", &"entrance")
	await get_tree().create_timer(4.2).timeout
	if _arg("--animations=", "yes") == "yes":
		await _animations()
	await _scenario_cooking()
	await _scenario_service()

func _animations() -> void:
	var names := ["down","left","right","up"]
	var actions: Array[StringName] = [&"move_down",&"move_left",&"move_right",&"move_up"]
	var directions := [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP]
	var starts := [Vector2(270,180),Vector2(300,160),Vector2(240,160),Vector2(270,250)]
	for i in range(4):
		main.player.global_position = starts[i]
		main.player.facing = directions[i]
		for frame in range(12):
			await get_tree().create_timer(0.12).timeout
			await _actor_frame("idle_"+names[i],frame)
		main.player.global_position = starts[i]
		Input.action_press(actions[i])
		for frame in range(12):
			await get_tree().create_timer(0.10).timeout
			await _actor_frame("walk_"+names[i],frame)
		Input.action_release(actions[i])
		await _frames(2)

func _actor_frame(label: String, frame: int) -> void:
	var image := await _grab()
	var pos := Vector2i(main.player.get_global_transform_with_canvas().origin)
	var crop := image.get_region(Rect2i(pos+Vector2i(-32,-72),Vector2i(64,80)))
	var frames := _out.path_join("frames")
	DirAccess.make_dir_recursive_absolute(frames)
	crop.save_png(frames.path_join("%s_%02d.png" % [label,frame]))
	if label == "walk_down":
		image.save_png(frames.path_join("world_walk_%02d.png" % frame))
