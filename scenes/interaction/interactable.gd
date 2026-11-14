class_name Interactable
extends Area2D
## Something the player can use with the interact action. The owning scene connects `interacted`
## and keeps `prompt` / `enabled` up to date. Lives on physics layer 3 ("interactable").

signal interacted(player: Player)

@export var prompt := "Use"
@export var enabled := true


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	monitoring = false
	monitorable = true


func interact(player: Player) -> void:
	if enabled:
		interacted.emit(player)
