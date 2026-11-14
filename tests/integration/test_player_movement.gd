extends TestCase
## Player controller driven by real input actions and real physics.

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const START := Vector2(100, 100)
const MOVE_ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down"]

var player: Player


func before_each() -> void:
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = START
	await wait_physics_frames(1)


func after_each() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)
	player.queue_free()
	await wait_frames(1)


func test_holding_right_moves_at_walk_speed() -> void:
	Input.action_press(&"move_right")
	await wait_physics_frames(30)  # half a second at 60 Hz
	Input.action_release(&"move_right")
	assert_almost_eq(player.global_position.x - START.x, player.speed * 0.5, player.speed * 0.08)
	assert_almost_eq(player.global_position.y, START.y, 0.01)


func test_releasing_input_stops_immediately() -> void:
	Input.action_press(&"move_down")
	await wait_physics_frames(10)
	Input.action_release(&"move_down")
	await wait_physics_frames(1)
	var stopped_at := player.global_position
	await wait_physics_frames(10)
	assert_eq(player.global_position, stopped_at)


func test_diagonal_movement_is_not_faster() -> void:
	Input.action_press(&"move_right")
	Input.action_press(&"move_down")
	await wait_physics_frames(30)
	assert_almost_eq(player.global_position.distance_to(START), player.speed * 0.5, player.speed * 0.08)


func test_faces_the_direction_of_travel() -> void:
	Input.action_press(&"move_left")
	await wait_physics_frames(4)
	Input.action_release(&"move_left")
	assert_eq(player.facing, Vector2.LEFT)
	Input.action_press(&"move_up")
	await wait_physics_frames(4)
	Input.action_release(&"move_up")
	assert_eq(player.facing, Vector2.UP)


func test_walk_frames_use_facing_row_and_idle_frame_when_stopped() -> void:
	Input.action_press(&"move_left")
	await wait_physics_frames(20)
	var walking_frame := player.sprite.frame
	Input.action_release(&"move_left")
	await wait_physics_frames(2)
	assert_eq(walking_frame / 5, 1, "row 1 is the left-facing row")
	assert_true(walking_frame % 5 >= 1, "a walk column is shown while moving")
	assert_eq(player.sprite.frame, 5, "idle column of the left row when stopped")


func test_sheet_with_two_idle_and_six_walk_frames_uses_its_own_columns() -> void:
	player.idle_frames = 2
	player.walk_frames = 6
	player.sprite.hframes = 8
	Input.action_press(&"move_left")
	var walk_columns := {}
	for i in 40:
		await wait_physics_frames(1)
		walk_columns[player.sprite.frame % 8] = true
		assert_eq(player.sprite.frame / 8, 1, "left row of an 8-column sheet")
	Input.action_release(&"move_left")
	for column: int in walk_columns:
		assert_true(column >= 2, "walk column %d must skip the idle columns" % column)
	assert_true(walk_columns.size() >= 4, "walk cycles through its frames: %s" % [walk_columns.keys()])
	var idle_columns := {}
	for i in 90:
		await wait_physics_frames(1)
		idle_columns[player.sprite.frame % 8] = true
	assert_eq(idle_columns.keys().filter(func(c: int) -> bool: return c > 1), [], "idle stays in columns 0-1")
	assert_eq(idle_columns.size(), 2, "both idle frames are shown")


func test_walls_block_movement() -> void:
	var wall := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 200)
	shape.shape = rect
	wall.add_child(shape)
	wall.position = Vector2(140, 100)
	add_child(wall)
	await wait_physics_frames(1)
	Input.action_press(&"move_right")
	await wait_physics_frames(60)
	assert_true(player.global_position.x <= 140 - 8 - 7 + 0.5,
			"feet box must stop at the wall face, got x=%s" % player.global_position.x)
	wall.queue_free()


func test_disabled_input_freezes_the_player() -> void:
	player.input_enabled = false
	Input.action_press(&"move_right")
	await wait_physics_frames(20)
	assert_eq(player.global_position, START)
