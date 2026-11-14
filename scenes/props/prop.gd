@tool
class_name Prop
extends StaticBody2D
## A Y-sortable world object: a sprite whose `foot_row` (texture row touching the ground) sits on
## this node's origin, plus an optional ground-level blocker. Used for trees, rocks, furniture, ...
## Children are created internally, so instances only store these exported properties.

@export var texture: Texture2D:
	set(value):
		texture = value
		_refresh()
## Texture row that rests on the ground; -1 means the bottom row.
@export var foot_row: int = -1:
	set(value):
		foot_row = value
		_refresh()
## Size of the solid footprint at the base. Zero means the prop does not block movement.
@export var blocker_size := Vector2.ZERO:
	set(value):
		blocker_size = value
		_refresh()
@export var blocker_offset := Vector2.ZERO:
	set(value):
		blocker_offset = value
		_refresh()
@export var flip_h := false:
	set(value):
		flip_h = value
		_refresh()
## Fade the sprite while the player stands behind it (tall props such as trees), so the player
## is never completely hidden.
@export var fade_when_behind := false:
	set(value):
		fade_when_behind = value
		_refresh()

const FADED_ALPHA := 0.45
const FADE_SECONDS := 0.18
## Feet this far above the base count as "behind" (smaller gaps read as standing beside it).
const BEHIND_MARGIN := 6.0

var sprite: Sprite2D
var _shape: CollisionShape2D
var _occlusion: Area2D
var _occluded_bodies := 0
var _fade_tween: Tween


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = false
		add_child(sprite, false, Node.INTERNAL_MODE_FRONT)
	sprite.texture = texture
	sprite.flip_h = flip_h
	if texture != null:
		var foot := foot_row if foot_row >= 0 else texture.get_height() - 1
		sprite.offset = Vector2(-floori(texture.get_width() / 2.0), -(foot + 1))
		_refresh_occlusion(foot)
	if blocker_size == Vector2.ZERO:
		if _shape != null:
			_shape.queue_free()
			_shape = null
		return
	if _shape == null:
		_shape = CollisionShape2D.new()
		_shape.shape = RectangleShape2D.new()
		add_child(_shape, false, Node.INTERNAL_MODE_FRONT)
	(_shape.shape as RectangleShape2D).size = blocker_size
	_shape.position = Vector2(0, -blocker_size.y / 2.0) + blocker_offset


func _refresh_occlusion(foot: int) -> void:
	if not fade_when_behind or Engine.is_editor_hint():
		return
	if _occlusion == null:
		_occlusion = Area2D.new()
		_occlusion.collision_layer = 0
		_occlusion.collision_mask = 2  # player
		_occlusion.monitorable = false
		var area_shape := CollisionShape2D.new()
		area_shape.shape = RectangleShape2D.new()
		_occlusion.add_child(area_shape)
		add_child(_occlusion, false, Node.INTERNAL_MODE_FRONT)
		_occlusion.body_entered.connect(_on_occlusion_changed.bind(1))
		_occlusion.body_exited.connect(_on_occlusion_changed.bind(-1))
	var area_shape := _occlusion.get_child(0) as CollisionShape2D
	var height := (foot + 1) - BEHIND_MARGIN
	(area_shape.shape as RectangleShape2D).size = Vector2(texture.get_width() * 0.8, height)
	area_shape.position = Vector2(0, -BEHIND_MARGIN - height / 2.0)


func _on_occlusion_changed(body: Node2D, change: int) -> void:
	if not body is Player:
		return
	_occluded_bodies = maxi(0, _occluded_bodies + change)
	if _fade_tween != null:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(sprite, "modulate:a", FADED_ALPHA if _occluded_bodies > 0 else 1.0,
			FADE_SECONDS)
