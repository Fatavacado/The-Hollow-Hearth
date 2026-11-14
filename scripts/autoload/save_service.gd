extends Node
## Save file access (autoload "SaveService"). Writes are atomic: the new save goes to a temporary
## file that then replaces the old one, so a crash mid-save never destroys the previous save.

const DEFAULT_PATH := "user://savegame.json"

## Tests point this somewhere else so they never touch the player's real save.
var save_path := DEFAULT_PATH


func has_save() -> bool:
	_recover_interrupted_save()
	return FileAccess.file_exists(save_path)


func save_game(player_position: Vector2) -> Error:
	var text := JSON.stringify(SaveData.capture(GameState, player_position), "\t")
	var temp_path := save_path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.close()
	if FileAccess.file_exists(save_path):
		var removed := DirAccess.remove_absolute(save_path)
		if removed != OK:
			return removed
	return DirAccess.rename_absolute(temp_path, save_path)


## Applies the save to GameState. See SaveData.apply for the result format.
func load_game() -> Dictionary:
	if not has_save():
		return {"ok": false, "error": "No saved game found."}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(save_path)) != OK or not json.data is Dictionary:
		return {"ok": false, "error": "The save file is damaged and could not be read."}
	return SaveData.apply(json.data, GameState)


func delete_save() -> void:
	for path in [save_path, save_path + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


## A crash between removing the old save and renaming the new one leaves only the temp file.
func _recover_interrupted_save() -> void:
	var temp_path := save_path + ".tmp"
	if not FileAccess.file_exists(save_path) and FileAccess.file_exists(temp_path):
		DirAccess.rename_absolute(temp_path, save_path)
