extends Node
## Mutable runtime state for the current play session (autoload "GameState").
## Definitions (items, recipes, guests) are immutable Resources in GameDB; anything that
## changes during play lives here so it can be reset, saved and loaded in one place.

## Emitted when something (a door, a menu) asks to move the player to another world.
signal travel_requested(world_id: StringName, spawn_id: StringName)

var location: StringName = &"tavern"
var play_time: float = 0.0
var session_active: bool = false


func _process(delta: float) -> void:
	advance_time(delta)


func new_game() -> void:
	location = &"tavern"
	play_time = 0.0
	session_active = true


func end_session() -> void:
	session_active = false


func advance_time(seconds: float) -> void:
	if session_active:
		play_time += seconds


func request_travel(world_id: StringName, spawn_id: StringName) -> void:
	travel_requested.emit(world_id, spawn_id)
