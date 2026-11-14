extends Node
## Mutable runtime state for the current play session (autoload "GameState").
## Definitions (items, recipes, guests) are immutable Resources in GameDB; anything that
## changes during play lives here so it can be reset, saved and loaded in one place.

## Emitted when something (a door, a menu) asks to move the player to another world.
signal travel_requested(world_id: StringName, spawn_id: StringName)

const BASE_SATCHEL_CAPACITY := 10

var location: StringName = &"tavern"
var play_time: float = 0.0
var session_active: bool = false
## Carried ingredients (limited). The same object lives for the whole session; reset, never replace.
var satchel := Inventory.new(BASE_SATCHEL_CAPACITY)
## Tavern storage (unlimited).
var pantry := Inventory.new(Inventory.UNLIMITED)
## Gather-node runtime state by node id; see Gathering for the format.
var gather_nodes: Dictionary = {}


func _process(delta: float) -> void:
	advance_time(delta)


func new_game() -> void:
	location = &"tavern"
	play_time = 0.0
	session_active = true
	satchel.load_counts({})
	satchel.set_capacity(BASE_SATCHEL_CAPACITY)
	pantry.load_counts({})
	gather_nodes.clear()


func end_session() -> void:
	session_active = false


func advance_time(seconds: float) -> void:
	if session_active:
		play_time += seconds


func request_travel(world_id: StringName, spawn_id: StringName) -> void:
	travel_requested.emit(world_id, spawn_id)


## Harvests a gather node into the satchel. Returns how many items were gathered.
func gather(node_id: StringName, item_id: StringName, max_yield: int, regrow_seconds: float) -> int:
	var result := Gathering.harvest(gather_nodes.get(node_id, {}), max_yield, regrow_seconds,
			play_time, satchel, item_id)
	if result.gathered > 0:
		gather_nodes[node_id] = result.state
	return result.gathered


func node_remaining(node_id: StringName, max_yield: int, regrow_seconds: float) -> int:
	return Gathering.remaining(gather_nodes.get(node_id, {}), max_yield, regrow_seconds, play_time)
