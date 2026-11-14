@tool
class_name Seat
extends Marker2D
## A place a guest can sit. `approach` lists the waypoints (in tavern coordinates) a guest walks
## through from the door before reaching this seat; `facing` is the direction it faces when seated.

@export var approach: PackedVector2Array = PackedVector2Array()
@export var facing := Vector2.RIGHT

var occupant: Node = null


func is_free() -> bool:
	return occupant == null or not is_instance_valid(occupant)


func approach_path() -> PackedVector2Array:
	var path := approach.duplicate()
	path.append(global_position)
	return path
