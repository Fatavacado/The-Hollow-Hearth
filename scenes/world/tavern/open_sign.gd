extends Prop
## The tavern's OPEN / CLOSED sign: the player's explicit control over service.

const OPEN_TEXTURE := preload("res://assets/art/props/sign_open.png")
const CLOSED_TEXTURE := preload("res://assets/art/props/sign_closed.png")

@onready var _use: Interactable = $Interactable


func _ready() -> void:
	super()
	_use.interacted.connect(func(_player: Player) -> void: GameState.set_tavern_open(not GameState.tavern_open))
	GameState.tavern_open_changed.connect(_show_state)
	_show_state(GameState.tavern_open)


func _show_state(is_open: bool) -> void:
	texture = OPEN_TEXTURE if is_open else CLOSED_TEXTURE
	_use.prompt = "Close the tavern" if is_open else "Open the tavern"
