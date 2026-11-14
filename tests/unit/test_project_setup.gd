extends TestCase
## Guards the toolchain pin and the project-level settings the art pipeline depends on.


func test_running_on_pinned_engine_version() -> void:
	# docs/DEVELOPMENT.md pins Godot 4.7.2-stable; a different engine must fail loudly.
	var v := Engine.get_version_info()
	assert_eq("%d.%d.%d-%s" % [v.major, v.minor, v.patch, v.status], "4.7.2-stable")


func test_pixel_art_renders_without_filtering_or_fractional_scaling() -> void:
	assert_eq(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"), 0,
			"canvas textures must default to nearest-neighbour")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "viewport",
			"world must render at native resolution then upscale")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer",
			"upscale must be integer to avoid uneven pixels")


func test_movement_keys_drive_movement_actions() -> void:
	var cases := {
		KEY_W: &"move_up", KEY_UP: &"move_up",
		KEY_S: &"move_down", KEY_DOWN: &"move_down",
		KEY_A: &"move_left", KEY_LEFT: &"move_left",
		KEY_D: &"move_right", KEY_RIGHT: &"move_right",
	}
	for key: Key in cases:
		assert_true(_key_event(key).is_action(cases[key]),
				"%s should trigger %s" % [OS.get_keycode_string(key), cases[key]])


func test_interaction_menu_and_pause_keys_are_bound() -> void:
	assert_true(_key_event(KEY_E).is_action(&"interact"), "E interacts")
	assert_true(_key_event(KEY_SPACE).is_action(&"interact"), "Space interacts")
	assert_true(_key_event(KEY_TAB).is_action(&"inventory"), "Tab opens inventory")
	assert_true(_key_event(KEY_ESCAPE).is_action(&"pause"), "Escape pauses")


func test_gamepad_face_button_interacts() -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_A
	event.pressed = true
	assert_true(event.is_action(&"interact"))


func _key_event(key: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	return event
