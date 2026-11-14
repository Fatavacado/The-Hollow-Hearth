class_name Main
extends Node
## Game root: owns the current world, the player and the transitions between worlds.

const WORLD_SCENES := {
	&"tavern": preload("res://scenes/world/tavern/tavern.tscn"),
	&"forest": preload("res://scenes/world/forest/forest.tscn"),
}
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const FADE_SECONDS := 0.25
const BANNER_SECONDS := 2.2

var current_world: World
var player: Player
var _traveling := false
var _banner_tween: Tween

@onready var hud: HUD = $HUD
@onready var cooking_panel: CookingPanel = %CookingPanel
@onready var upgrade_panel: UpgradePanel = %UpgradePanel
@onready var _world_slot: Node2D = $WorldSlot
@onready var _fade: ColorRect = %Fade
@onready var _banner: Label = %Banner


func _ready() -> void:
	GameState.travel_requested.connect(_on_travel_requested)
	Feedback.panel_requested.connect(_on_panel_requested)
	cooking_panel.closed.connect(_on_panel_closed)
	upgrade_panel.closed.connect(_on_panel_closed)
	start_new_game()


func _on_panel_requested(panel_id: StringName) -> void:
	if _traveling:
		return
	match panel_id:
		&"cooking":
			player.input_enabled = false
			cooking_panel.open()
		&"upgrades":
			player.input_enabled = false
			upgrade_panel.open()


func _on_panel_closed() -> void:
	if not _traveling:
		player.input_enabled = true


func start_new_game() -> void:
	GameState.new_game()
	_enter_world(&"tavern", &"start")


func is_traveling() -> bool:
	return _traveling


func _on_travel_requested(world_id: StringName, spawn_id: StringName) -> void:
	if _traveling or not WORLD_SCENES.has(world_id):
		return
	_traveling = true
	player.input_enabled = false
	if world_id != &"tavern" and GameState.tavern_open:
		# Guests only exist while the keeper is home: heading out closes up, no penalty.
		GameState.set_tavern_open(false)
	await _tween_fade(1.0)
	_enter_world(world_id, spawn_id)
	await _tween_fade(0.0)
	player.input_enabled = true
	_traveling = false


func _enter_world(world_id: StringName, spawn_id: StringName) -> void:
	if player == null:
		player = PLAYER_SCENE.instantiate()
		hud.player = player
	if player.get_parent() != null:
		player.get_parent().remove_child(player)
	if current_world != null:
		_world_slot.remove_child(current_world)
		current_world.queue_free()
	var world: World = WORLD_SCENES[world_id].instantiate()
	_world_slot.add_child(world)
	current_world = world
	player.position = world.get_spawn_position(spawn_id)
	world.add_actor(player)
	player.set_camera_limits(world.get_camera_limits())
	GameState.location = world_id
	_show_banner(world.display_name)


func _tween_fade(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_SECONDS)
	await tween.finished


func _show_banner(text: String) -> void:
	if _banner_tween != null:
		_banner_tween.kill()
	_banner.text = text
	_banner.modulate.a = 0.0
	_banner_tween = create_tween()
	_banner_tween.tween_property(_banner, "modulate:a", 1.0, 0.3)
	_banner_tween.tween_interval(BANNER_SECONDS)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.6)
