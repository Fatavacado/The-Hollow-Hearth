extends Node2D
## The tavern hearth: cooking station with animated fire, a flickering warm light and steam
## from the cauldron while a dish cooks.

const FIRE_FPS := 8.0

var _time := 0.0
var _base_energy := 1.0
var _cooking := false

@onready var _fire: Sprite2D = $Fire
@onready var _pot: Sprite2D = $Cauldron
@onready var _light: PointLight2D = $Light
@onready var _steam: CPUParticles2D = $Steam
@onready var _use: Interactable = $Interactable


func _ready() -> void:
	_base_energy = _light.energy
	_use.prompt = "Cook at the hearth"
	_use.interacted.connect(func(_player: Player) -> void: Feedback.open_panel(&"cooking"))
	Feedback.cooking_changed.connect(_on_cooking_changed)


func _process(delta: float) -> void:
	_time += delta
	_fire.frame = int(_time * FIRE_FPS) % _fire.hframes
	var boost := 0.25 if _cooking else 0.0
	_light.energy = _base_energy + boost + sin(_time * 7.3) * 0.06 + sin(_time * 13.1) * 0.04
	_pot.offset.y = -1.0 if _cooking and int(_time * 10.0) % 2 == 0 else 0.0


func _on_cooking_changed(active: bool) -> void:
	_cooking = active
	_steam.emitting = active
