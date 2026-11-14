class_name GameSession
extends TestCase
## Base for integration tests that drive the real Main scene with real input events.

var main: Main
var toasts: PackedStringArray = []


func before_each() -> void:
	main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await wait_frames(2)
	main.start_new_game()
	toasts.clear()
	Feedback.toast_requested.connect(_record_toast)
	await wait_frames(2)


func after_each() -> void:
	Feedback.toast_requested.disconnect(_record_toast)
	for action: StringName in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)
	main.queue_free()
	await wait_frames(2)


func travel(world_id: StringName, spawn_id: StringName) -> void:
	GameState.request_travel(world_id, spawn_id)
	assert_true(await arrive(world_id), "arrived in %s" % world_id)


func arrive(world_id: StringName, max_physics_frames: int = 240) -> bool:
	for i in max_physics_frames:
		if main.current_world != null and main.current_world.world_id == world_id and not main.is_traveling():
			return true
		await get_tree().physics_frame
	return false


## Puts the player just in front of `target` (south of it), facing it, and lets physics settle.
func stand_before(target: Node2D, distance: float = 14.0) -> void:
	main.player.global_position = target.global_position + Vector2(0, distance)
	main.player.facing = Vector2.UP
	await wait_physics_frames(3)


func press(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
	await wait_frames(2)


func nodes_of_type(type_check: Callable) -> Array:
	var out := []
	_collect(main.current_world, type_check, out)
	return out


func last_toast() -> String:
	return toasts[-1] if not toasts.is_empty() else ""


func _collect(node: Node, type_check: Callable, out: Array) -> void:
	for child in node.get_children():
		if type_check.call(child):
			out.append(child)
		_collect(child, type_check, out)


func _record_toast(text: String, _icon: Texture2D) -> void:
	toasts.append(text)
