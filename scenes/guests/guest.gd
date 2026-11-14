class_name Guest
extends Node2D
## A visiting guest: walks in from the door, sits, shows its order and waits (patiently), eats when
## served, pays, then leaves. Guests are transient — they exist only while the tavern is loaded.

signal finished(guest: Guest)

enum State { ARRIVING, WAITING, EATING, LEAVING }

const COIN_ICON := preload("res://assets/art/items/coin.png")
const HEART := preload("res://assets/art/ui/emote_heart.png")
const SAD := preload("res://assets/art/ui/emote_sad.png")
const FLOATING_TEXT := preload("res://scenes/ui/floating_text.gd")
const ROW_BY_FACING := {Vector2.DOWN: 0, Vector2.LEFT: 1, Vector2.RIGHT: 2, Vector2.UP: 3}

var data: GuestData
var order: RecipeData
var seat: Seat
var state := State.ARRIVING
var patience_left := 0.0

var _path := PackedVector2Array()
var _path_index := 0
var _entry := Vector2.ZERO
var _eat_left := 0.0
var _anim_time := 0.0
var _facing := Vector2.UP
var _moving := false

@onready var _sprite: Sprite2D = $Sprite
@onready var _bubble: Node2D = $Bubble
@onready var _dish_icon: Sprite2D = $Bubble/Dish
@onready var _patience_fill: ColorRect = $Bubble/PatienceFill
@onready var _patience_back: ColorRect = $Bubble/PatienceBack
@onready var _emote: Sprite2D = $Emote
@onready var _use: Interactable = $Interactable


func setup(guest_data: GuestData, recipe: RecipeData, target_seat: Seat, entry: Vector2) -> void:
	data = guest_data
	order = recipe
	seat = target_seat
	seat.occupant = self
	_entry = entry
	position = entry
	_path = seat.approach_path()
	patience_left = data.patience_seconds


func _ready() -> void:
	_sprite.texture = data.sprite_sheet
	_sprite.hframes = data.sheet_columns
	_sprite.vframes = data.sheet_rows
	if data.floats:
		_sprite.modulate.a = 0.92
	_dish_icon.texture = order.output.icon
	_bubble.hide()
	_emote.hide()
	_use.enabled = false
	_use.interacted.connect(_on_interacted)
	Feedback.toast(data.arrival_line)


func is_waiting() -> bool:
	return state == State.WAITING


func _process(delta: float) -> void:
	_anim_time += delta
	match state:
		State.ARRIVING:
			if _walk(delta):
				_sit()
		State.WAITING:
			patience_left -= delta
			_patience_fill.size.x = 18.0 * clampf(patience_left / data.patience_seconds, 0.0, 1.0)
			_patience_fill.color = Color(0.66, 0.88, 0.45) if patience_left > data.patience_seconds * 0.3 \
					else Color(0.96, 0.5, 0.45)
			if patience_left <= 0.0:
				_leave(false)
		State.EATING:
			_eat_left -= delta
			if _eat_left <= 0.0:
				_pay_and_leave()
		State.LEAVING:
			if _walk(delta):
				finished.emit(self)
				queue_free()
	_animate()


## Moves along the path; returns true once the last point is reached.
func _walk(delta: float) -> bool:
	_moving = _path_index < _path.size()
	if not _moving:
		return true
	var target := _path[_path_index]
	var to_target := target - position
	var step := data.walk_speed * delta
	if absf(to_target.x) > absf(to_target.y):
		_facing = Vector2.RIGHT if to_target.x > 0.0 else Vector2.LEFT
	elif to_target != Vector2.ZERO:
		_facing = Vector2.DOWN if to_target.y > 0.0 else Vector2.UP
	if to_target.length() <= step:
		position = target
		_path_index += 1
		return _path_index >= _path.size()
	position += to_target.normalized() * step
	return false


func _sit() -> void:
	state = State.WAITING
	_moving = false
	_facing = seat.facing
	_bubble.show()
	_use.prompt = "Serve %s" % order.output.display_name
	_use.enabled = true


func _on_interacted(_player: Player) -> void:
	if state != State.WAITING:
		return
	if not GameState.counter.remove(order.output.id, 1):
		Feedback.toast("No %s on the counter yet. Cook one at the hearth." % order.output.display_name,
				order.output.icon)
		return
	state = State.EATING
	_eat_left = data.eat_seconds
	_use.enabled = false
	_patience_fill.hide()
	_patience_back.hide()


func _pay_and_leave() -> void:
	var amount := Orders.payment(data, order.output)
	GameState.earn(amount)
	GameState.record_served()
	var line := data.favorite_line if Orders.is_favorite(data, order.output) else data.thanks_line
	Feedback.toast("+%d coins   %s" % [amount, line], COIN_ICON)
	var floating := FLOATING_TEXT.new()
	floating.text = "+%d" % amount
	floating.position = position + Vector2(0, -70)
	get_parent().add_child(floating)
	_show_emote(HEART)
	_leave(true)


func _leave(happy: bool) -> void:
	state = State.LEAVING
	_bubble.hide()
	_use.enabled = false
	if not happy:
		Feedback.toast(data.leave_line)
		_show_emote(SAD)
	if seat != null:
		seat.occupant = null
		seat = null
	var back := _path.duplicate()
	back.reverse()
	back.append(_entry)
	_path = back
	_path_index = 0


func _show_emote(texture: Texture2D) -> void:
	_emote.texture = texture
	_emote.show()
	var tween := create_tween()
	_emote.modulate.a = 1.0
	tween.tween_interval(1.4)
	tween.tween_property(_emote, "modulate:a", 0.0, 0.4)


func _animate() -> void:
	if data.floats:
		_sprite.frame = int(_anim_time * 3.0) % _sprite.hframes
		_sprite.offset.y = -61.0 - 3.0 + roundf(sin(_anim_time * 2.6) * 2.0)
		_sprite.flip_h = _facing == Vector2.LEFT
		return
	var column := 1 + int(_anim_time * 8.0) % 4 if _moving else 0
	_sprite.frame = ROW_BY_FACING[_facing] * data.sheet_columns + column
