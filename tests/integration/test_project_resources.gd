extends TestCase
## Scene/resource validation: every scene and resource in the project must load and every
## scene must instance. Missing ext_resources or broken scripts surface here as engine
## errors (captured by the runner) or null loads.

const SKIP_DIRS: PackedStringArray = [".godot", ".git", "addons", "tools"]


func test_every_scene_loads_and_instantiates() -> void:
	var scenes := _collect_files("res://", ["tscn", "scn"])
	assert_true(scenes.size() > 0, "expected at least one scene")
	for path in scenes:
		var packed := load(path) as PackedScene
		if packed == null:
			fail("scene failed to load: %s" % path)
			continue
		var instance := packed.instantiate()
		if instance == null:
			fail("scene failed to instantiate: %s" % path)
			continue
		instance.free()


func test_every_resource_file_loads() -> void:
	for path in _collect_files("res://", ["tres", "res"]):
		if load(path) == null:
			fail("resource failed to load: %s" % path)


func test_main_scene_runs_for_a_second_without_errors() -> void:
	var main_path: String = ProjectSettings.get_setting("application/run/main_scene")
	var main := (load(main_path) as PackedScene).instantiate()
	add_child(main)
	await wait_frames(60)
	assert_true(is_instance_valid(main) and main.is_inside_tree(), "main scene stays alive")
	main.queue_free()
	await wait_frames(2)


func _collect_files(root: String, extensions: Array) -> PackedStringArray:
	var out: PackedStringArray = []
	for dir_name in DirAccess.get_directories_at(root):
		if dir_name in SKIP_DIRS or dir_name.begins_with("."):
			continue
		out.append_array(_collect_files(root.path_join(dir_name), extensions))
	for file_name in DirAccess.get_files_at(root):
		if file_name.get_extension() in extensions:
			out.append(root.path_join(file_name))
	return out
