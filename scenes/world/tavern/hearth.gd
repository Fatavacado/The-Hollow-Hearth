extends Node2D
## The tavern hearth: animated fire and a gently flickering warm light.

const FIRE_FPS := 8.0

@onready var _fire: Sprite2D = $Fire
@onready var _light: PointLight2D = $Light

var _time := 0.0
var _base_energy := 1.0


func _ready() -> void:
	_base_energy = _light.energy


func _process(delta: float) -> void:
	_time += delta
	_fire.frame = int(_time * FIRE_FPS) % _fire.hframes
	_light.energy = _base_energy + sin(_time * 7.3) * 0.06 + sin(_time * 13.1) * 0.04
