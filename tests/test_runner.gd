extends Node
## Headless test runner (no third-party framework; see docs/ARCHITECTURE.md).
##
##   godot --headless --path . res://tests/test_runner.tscn
##   godot --headless --path . res://tests/test_runner.tscn -- --filter=inventory
##
## Discovers `test_*.gd` files in TEST_DIRS, runs every `test_*` method and exits with
## code 0 when all pass, 1 otherwise. Engine/script errors logged while a test runs
## (for example a null dereference) fail that test even if no assertion did.

const TEST_DIRS: PackedStringArray = ["res://tests/unit", "res://tests/integration"]


class ErrorCollector:
	extends Logger
	var _mutex := Mutex.new()
	var _errors: PackedStringArray = []

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		var text := rationale if not rationale.is_empty() else code
		_mutex.lock()
		_errors.append("engine error: %s (%s:%d in %s)" % [text, file, line, function])
		_mutex.unlock()

	func take() -> PackedStringArray:
		_mutex.lock()
		var out := _errors.duplicate()
		_errors.clear()
		_mutex.unlock()
		return out


var _collector := ErrorCollector.new()


func _ready() -> void:
	OS.add_logger(_collector)
	# Never touch the player's real save while testing (autosaves happen during travel).
	SaveService.save_path = "user://test_run_save.json"
	_run_all.call_deferred()


func _run_all() -> void:
	var filter := _read_filter()
	var started_ms := Time.get_ticks_msec()
	var passed := 0
	var failed := 0
	var failed_names: PackedStringArray = []

	for script_path in _discover_test_scripts():
		var script := load(script_path) as GDScript
		if script == null or not script.can_instantiate():
			failed += 1
			failed_names.append(script_path)
			printerr("FAIL  %s (test script failed to load)" % script_path)
			continue
		for method_name in _test_methods(script):
			var full_name := "%s::%s" % [script_path.get_file().get_basename(), method_name]
			if not filter.is_empty() and not full_name.contains(filter):
				continue
			_collector.take()  # discard noise from between tests
			var case := script.new() as TestCase
			add_child(case)
			await case.run_test(method_name)
			var problems := case.failures.duplicate()
			problems.append_array(_collector.take())
			if problems.is_empty():
				passed += 1
				print("PASS  %s" % full_name)
			else:
				failed += 1
				failed_names.append(full_name)
				printerr("FAIL  %s" % full_name)
				for problem in problems:
					printerr("      - %s" % problem)
			case.queue_free()
			await get_tree().process_frame

	var seconds := (Time.get_ticks_msec() - started_ms) / 1000.0
	print("")
	print("%d passed, %d failed in %.2fs" % [passed, failed, seconds])
	for name in failed_names:
		print("  failed: %s" % name)
	OS.remove_logger(_collector)
	SaveService.delete_save()
	get_tree().quit(0 if failed == 0 and passed > 0 else 1)


func _discover_test_scripts() -> PackedStringArray:
	var found: PackedStringArray = []
	for dir_path in TEST_DIRS:
		for file_name in DirAccess.get_files_at(dir_path):
			if file_name.begins_with("test_") and file_name.ends_with(".gd"):
				found.append(dir_path.path_join(file_name))
	found.sort()
	return found


func _test_methods(script: GDScript) -> PackedStringArray:
	var names: PackedStringArray = []
	for method in script.get_script_method_list():
		var method_name: String = method["name"]
		if method_name.begins_with("test_") and not names.has(method_name):
			names.append(method_name)
	return names


func _read_filter() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--filter="):
			return arg.trim_prefix("--filter=")
	return ""
