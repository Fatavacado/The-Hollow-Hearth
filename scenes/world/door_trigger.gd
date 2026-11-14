class_name DoorTrigger
extends Area2D
## Walking the player into this area requests travel to `target_world` at `target_spawn`.

@export var target_world: StringName = &""
@export var target_spawn: StringName = &""


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # player
	monitorable = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.request_travel(target_world, target_spawn)
