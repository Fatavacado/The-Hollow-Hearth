extends TestCase
## Visual animation contract: rows, breathing idle and movement reset without changing physics.

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
var player: Player


func before_each() -> void:
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.set_physics_process(false)


func after_each() -> void:
	player.queue_free()
	await wait_frames(1)


func test_four_direction_idle_breaths_without_changing_world_position() -> void:
	var directions := [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]
	for row in range(4):
		player.facing = directions[row]
		player._idle_time = 0.0
		var before := player.position
		player._update_frame(0.1, false)
		assert_eq(player.sprite.frame, row * 5)
		player._update_frame(0.65, false)
		assert_eq(player.sprite.frame, row * 5 + 2)
		assert_eq(player.position, before, "breathing is a texture change, never body movement")
		player._update_frame(0.7, false)
		assert_eq(player.sprite.frame, row * 5)


func test_walking_uses_contact_and_passing_frames_then_stops_neutral() -> void:
	for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		player.facing = direction
		player._walk_time = 0.0
		var seen: Array[int] = []
		for i in range(4):
			player._update_frame(1.0 / player.walk_fps, true)
			seen.append(player.sprite.frame % 5)
		assert_true(seen.has(1) and seen.has(2) and seen.has(3) and seen.has(4))
		player._update_frame(0.02, false)
		assert_eq(player.sprite.frame % 5, 0)
		assert_almost_eq(player.speed, 110.0, 0.01, "art must not change movement speed")
