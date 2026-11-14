class_name Player
extends CharacterBody2D
## Four-direction top-down player. Sprite sheet layout (tools/art/gen_characters.py):
## rows down/left/right/up, columns idle + 4 walk frames.

const SHEET_COLUMNS := 5
const ROW_BY_FACING := {Vector2.DOWN: 0, Vector2.LEFT: 1, Vector2.RIGHT: 2, Vector2.UP: 3}

@export var speed := 110.0
@export var walk_fps := 9.0

var facing := Vector2.DOWN
var input_enabled := true
var _walk_time := 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var camera: Camera2D = $Camera


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if input_enabled:
		direction = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * speed
	move_and_slide()
	_update_facing(direction)
	_update_frame(delta, direction != Vector2.ZERO)


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
		_walk_time += delta * walk_fps
		column = 1 + int(_walk_time) % 4
	else:
		_walk_time = 0.0
	sprite.frame = ROW_BY_FACING[facing] * SHEET_COLUMNS + column
