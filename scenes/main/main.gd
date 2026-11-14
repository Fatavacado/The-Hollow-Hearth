extends Node
## Game root. Owns the active world scene, the HUD and screen transitions.
## M0: foundation placeholder that proves the project boots.

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	var v := Engine.get_version_info()
	_status_label.text = "The Hollow Hearth\nfoundation build — Godot %d.%d.%d" % [v.major, v.minor, v.patch]
