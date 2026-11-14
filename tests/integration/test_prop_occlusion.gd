extends TestCase
## Tall props fade while the player stands behind them, so the player never disappears.

const PROP_SCENE := preload("res://scenes/props/prop.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const TREE := preload("res://assets/art/props/oak_tree_a.png")

var tree: Prop
var player: Player


func before_each() -> void:
	tree = PROP_SCENE.instantiate()
	tree.texture = TREE
	tree.foot_row = 76
	tree.blocker_size = Vector2(16, 8)
	tree.fade_when_behind = true
	tree.position = Vector2(200, 200)
	add_child(tree)
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	await wait_physics_frames(2)


func after_each() -> void:
	tree.queue_free()
	player.queue_free()
	await wait_frames(1)


func test_prop_fades_when_player_is_behind_its_canopy() -> void:
	player.global_position = Vector2(200, 170)  # north of the trunk, under the canopy
	await wait_physics_frames(3)
	await wait_seconds(0.35)
	assert_true(tree.sprite.modulate.a < 0.7, "canopy alpha %s" % tree.sprite.modulate.a)


func test_prop_stays_opaque_when_player_is_in_front() -> void:
	player.global_position = Vector2(200, 230)  # south of the trunk, drawn in front of the tree
	await wait_physics_frames(3)
	await wait_seconds(0.35)
	assert_eq(tree.sprite.modulate.a, 1.0)


func test_prop_becomes_opaque_again_when_player_leaves() -> void:
	player.global_position = Vector2(200, 170)
	await wait_physics_frames(3)
	await wait_seconds(0.35)
	player.global_position = Vector2(320, 260)
	await wait_physics_frames(3)
	await wait_seconds(0.35)
	assert_eq(tree.sprite.modulate.a, 1.0)
