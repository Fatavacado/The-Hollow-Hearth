extends Node
## Scripted gameplay tour of the Copperfern benchmark for review videos. Drives the real input
## actions (no teleporting in the forest). Record with Godot's movie writer:
##   godot --path . --write-movie <dir>/frame.png --fixed-fps 30 res://tests/visual/tour_copperfern.tscn

const BENCH := preload("res://scenes/benchmark/copperfern/copperfern_benchmark.tscn")

var main: Main


func _ready() -> void:
	var bench := BENCH.instantiate()
	add_child(bench)
	main = bench.main
	await _wait(0.5)
	main.start_new_game()
	await _wait(3.0)  # arrival banner
	# tavern: a short walk past the counter and stove, then out through the door
	main.player.global_position = Vector2(300, 250)
	await _walk(&"move_left", 1.0)
	await _walk(&"move_up", 0.5)
	await _walk(&"move_right", 1.4)
	await _walk(&"move_down", 0.5)
	main.player.global_position = main.current_world.get_spawn_position(&"entrance")
	Input.action_press(&"move_down")
	while main.current_world.world_id != &"forest":
		await get_tree().process_frame
	Input.action_release(&"move_down")
	while main.is_traveling():
		await get_tree().process_frame
	await _wait(1.5)
	# forest: up the path to the glowcaps
	await _walk(&"move_up", 1.6)
	await _walk(&"move_left", 0.45)
	await _walk(&"move_up", 0.55)
	await _interact()
	# across the clearing to the moonberry bush
	await _walk(&"move_right", 2.4)
	await _walk(&"move_up", 0.4)
	await _interact()
	# back down past the trees, behind the tree on the right
	await _walk(&"move_down", 1.4)
	await _walk(&"move_left", 0.8)
	await _walk(&"move_down", 0.8)
	await _walk(&"move_left", 1.6)
	await _wait(1.0)
	print("tour satchel: glowcap=%d moonberry=%d" % [
			GameState.satchel.count(&"glowcap"), GameState.satchel.count(&"moonberry")])
	SaveService.delete_save()
	get_tree().quit()


func _walk(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await _wait(seconds)
	Input.action_release(action)


func _interact() -> void:
	await _wait(0.2)
	for pressed in [true, false]:  # interact is read as an input event, like a real key press
		var event := InputEventAction.new()
		event.action = &"interact"
		event.pressed = pressed
		Input.parse_input_event(event)
		await get_tree().physics_frame
	await _wait(1.2)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
