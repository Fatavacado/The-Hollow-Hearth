extends TestCase
## Save files on disk: atomic writes, missing and corrupt files.

const PATH := "user://unit_test_save.json"

var _previous_path := ""


func before_each() -> void:
	_previous_path = SaveService.save_path
	SaveService.save_path = PATH
	_delete(PATH)
	_delete(PATH + ".tmp")
	GameState.new_game()


func after_each() -> void:
	_delete(PATH)
	_delete(PATH + ".tmp")
	SaveService.save_path = _previous_path
	GameState.new_game()


func _delete(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func test_save_then_load_restores_state() -> void:
	GameState.earn(42)
	GameState.pantry.add(&"sweetroot", 3)
	assert_eq(SaveService.save_game(Vector2(100, 120)), OK)
	assert_true(SaveService.has_save())
	assert_false(FileAccess.file_exists(PATH + ".tmp"), "temporary file cleaned up")
	GameState.new_game()
	var result := SaveService.load_game()
	assert_true(result.ok, result.get("error", ""))
	assert_eq(GameState.coins, 42)
	assert_eq(GameState.pantry.count(&"sweetroot"), 3)


func test_saving_twice_replaces_the_previous_save() -> void:
	GameState.earn(1)
	SaveService.save_game(Vector2.ZERO)
	GameState.earn(1)
	SaveService.save_game(Vector2.ZERO)
	GameState.new_game()
	SaveService.load_game()
	assert_eq(GameState.coins, 2)


func test_loading_without_a_save_reports_it() -> void:
	assert_false(SaveService.has_save())
	var result := SaveService.load_game()
	assert_false(result.ok)


func test_corrupt_file_is_reported_and_state_kept() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("{ this is not json")
	file.close()
	GameState.earn(7)
	var result := SaveService.load_game()
	assert_false(result.ok)
	assert_eq(GameState.coins, 7)
