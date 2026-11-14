class_name GatherNode
extends Prop
## A harvestable ingredient source. Its runtime state lives in GameState (keyed by `node_id`),
## so picking survives leaving the forest; the sprite swaps between full and picked textures.

const REFRESH_SECONDS := 0.5

@export var node_id: StringName = &""
@export var item: ItemData
@export var max_yield := 2
@export var regrow_seconds := 120.0
@export var full_texture: Texture2D
@export var empty_texture: Texture2D

var _since_refresh := 0.0

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	super()
	_interactable.interacted.connect(_on_interacted)
	refresh_state()


func _process(delta: float) -> void:
	_since_refresh += delta
	if _since_refresh >= REFRESH_SECONDS:
		_since_refresh = 0.0
		refresh_state()


func available() -> int:
	return GameState.node_remaining(node_id, max_yield, regrow_seconds)


func refresh_state() -> void:
	var left := available()
	var wanted := full_texture if left > 0 else empty_texture
	if texture != wanted:
		texture = wanted
	_interactable.enabled = left > 0
	_interactable.prompt = "Gather %s" % item.display_name


func _on_interacted(_player: Player) -> void:
	var gathered := GameState.gather(node_id, item.id, max_yield, regrow_seconds)
	if gathered > 0:
		Feedback.toast("+%d %s" % [gathered, item.display_name], item.icon)
	elif GameState.satchel.free_space() == 0:
		Feedback.toast("Your satchel is full. Store ingredients in the tavern pantry.")
	refresh_state()
