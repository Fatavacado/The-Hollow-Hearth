extends Node
## Copperfern art benchmark entry point. Runs the real game (title, HUD, gathering, cooking panel,
## travel, saves) with the benchmark forest/tavern scenes and the Copperfern player sheet.
## The shipped slice is untouched: it still starts from scenes/main/main.tscn with its own art.
##
## Benchmark-only setup: saves go to their own file, and New Game stocks the pantry with one
## fernleaf and one sweetroot so the clearing's glowcaps and moonberries complete a recipe.

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const PLAYER_SHEET := preload("res://assets/art/benchmark/copperfern/player_runtime_v001.png")
const SAVE_PATH := "user://copperfern_benchmark_save.json"

var main: Main


func _ready() -> void:
	SaveService.save_path = SAVE_PATH
	main = MAIN_SCENE.instantiate()
	main.world_scenes = {
		&"tavern": preload("res://scenes/benchmark/copperfern/cf_tavern.tscn"),
		&"forest": preload("res://scenes/benchmark/copperfern/cf_forest.tscn"),
	}
	add_child(main)
	_dress_player(main.player)
	main.new_game_started.connect(_stock_pantry)


func _dress_player(player: Player) -> void:
	player.sprite.texture = PLAYER_SHEET
	player.sprite.hframes = 8
	player.sprite.vframes = 4
	player.sprite.offset = Vector2(-24, -58)  # anchor (24, 58): feet on the outline row
	player.idle_frames = 2
	player.walk_frames = 6
	player.walk_fps = 10.0
	player.idle_fps = 2.0
	player.sprite.frame = 0


func _stock_pantry() -> void:
	GameState.pantry.add(&"fernleaf", 1)
	GameState.pantry.add(&"sweetroot", 1)
	Feedback.toast("Copperfern benchmark: a fernleaf and a sweetroot wait in the pantry.")
