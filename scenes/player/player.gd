class_name Player
extends CharacterBody2D
## Four-direction top-down player. Codex v2 visual sheet (tools/art/codex_v2_player.py):
## rows down/left/right/up, columns idle + 4 walk frames.

const SHEET_COLUMNS := 5
const ROW_BY_FACING := {Vector2.DOWN: 0, Vector2.LEFT: 1, Vector2.RIGHT: 2, Vector2.UP: 3}

## How far ahead of the feet (in the facing direction) the interaction sensor sits.
const REACH := 14.0

@export var speed := 110.0
@export var walk_fps := 9.0

var facing := Vector2.DOWN
var input_enabled := true
## The interactable the player would use right now, or null.
var target: Interactable
var _walk_time := 0.0
## Visual-only breathing phase; does not affect movement, collision or interactions.
var _idle_time := 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera
@onready var _sensor: Area2D = $InteractionSensor


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if input_enabled:
		direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * speed
	move_and_slide()
	_update_facing(direction)
	_update_frame(delta, direction != Vector2.ZERO)
	_update_target()


func _unhandled_input(event: InputEvent) -> void:
	if input_enabled and event.is_action_pressed(&"interact") and try_interact():
		get_viewport().set_input_as_handled()


## Uses the current target. Returns false when there is nothing usable in reach.
func try_interact() -> bool:
	if target == null or not is_instance_valid(target) or not target.enabled:
		return false
	target.interact(self)
	return true


func _update_target() -> void:
	_sensor.position = facing * REACH + Vector2(0, -6)
	var best: Interactable = null
	var best_distance := INF
	if input_enabled:
		for area in _sensor.get_overlapping_areas():
			if area is Interactable and area.enabled:
				var d := area.global_position.distance_squared_to(_sensor.global_position)
				if d < best_distance:
					best = area
					best_distance = d
	target = best


func set_camera_limits(limits: Rect2i) -> void:
	camera.limit_left = limits.position.x
	camera.limit_top = limits.position.y
	camera.limit_right = limits.end.x
	camera.limit_bottom = limits.end.y
	camera.reset_smoothing()


func _update_facing(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	if absf(direction.x) > absf(direction.y):
		facing = Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
	elif absf(direction.y) > absf(direction.x):
		facing = Vector2.DOWN if direction.y > 0.0 else Vector2.UP
	elif facing.dot(direction) <= 0.0:
		# Exact diagonal: keep the current facing if it is one of the two directions.
		facing = Vector2.DOWN if direction.y > 0.0 else Vector2.UP


func _update_frame(delta: float, moving: bool) -> void:
	var column := 0
	if moving:
		_idle_time = 0.0
		_walk_time += delta * walk_fps
		column = 1 + int(_walk_time) % 4
	else:
		_walk_time = 0.0
		_idle_time += delta
		# Passing pose has a neutral foot stance and one-pixel upper-body breath.
		column = 2 if int(_idle_time / 0.7) % 2 == 1 else 0
	sprite.frame = ROW_BY_FACING[facing] * SHEET_COLUMNS + column
