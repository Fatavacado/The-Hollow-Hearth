class_name HUD
extends CanvasLayer
## Always-on game UI: satchel counter, interaction prompt, pickup toasts and the inventory panel.

const TOAST_SECONDS := 2.6
const MAX_TOASTS := 4

var player: Player

@onready var _satchel_label: Label = %SatchelLabel
@onready var _coins_label: Label = %CoinsLabel
@onready var _status_panel: PanelContainer = %TavernStatus
@onready var _status_label: Label = %TavernStatusLabel
@onready var _prompt_panel: PanelContainer = %PromptPanel
@onready var _prompt_label: Label = %PromptLabel
@onready var _toasts: VBoxContainer = %Toasts
@onready var _inventory_panel: PanelContainer = %InventoryPanel
@onready var _inventory_list: VBoxContainer = %InventoryList


func _ready() -> void:
	GameState.satchel.changed.connect(_on_inventory_changed)
	GameState.pantry.changed.connect(_on_inventory_changed)
	Feedback.toast_requested.connect(_show_toast)
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.tavern_open_changed.connect(_on_tavern_open_changed)
	_inventory_panel.hide()
	_prompt_panel.hide()
	_on_inventory_changed()
	_on_coins_changed(GameState.coins)
	_on_tavern_open_changed(GameState.tavern_open)


func tavern_status_text() -> String:
	return _status_label.text


func _on_coins_changed(coins: int) -> void:
	_coins_label.text = str(coins)


func _on_tavern_open_changed(is_open: bool) -> void:
	_status_label.text = "OPEN" if is_open else "CLOSED"
	_status_label.theme_type_variation = &"GoodLabel" if is_open else &"MutedLabel"


func _process(_delta: float) -> void:
	_status_panel.visible = GameState.location == &"tavern"
	var target: Interactable = null
	if player != null and is_instance_valid(player):
		target = player.target
	if target != null:
		_prompt_label.text = "[E] %s" % target.prompt
		_prompt_panel.show()
	else:
		_prompt_panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()
	elif _inventory_panel.visible and event.is_action_pressed(&"ui_cancel"):
		_inventory_panel.hide()
		get_viewport().set_input_as_handled()


func toggle_inventory() -> void:
	_inventory_panel.visible = not _inventory_panel.visible
	if _inventory_panel.visible:
		_rebuild_inventory()


func satchel_text() -> String:
	return "%d/%d" % [GameState.satchel.total(), GameState.satchel.capacity]


func prompt_text() -> String:
	return _prompt_label.text if _prompt_panel.visible else ""


func inventory_visible() -> bool:
	return _inventory_panel.visible


func inventory_text() -> String:
	var parts: PackedStringArray = []
	for label in _inventory_list.find_children("*", "Label", true, false):
		parts.append((label as Label).text)
	return " ".join(parts)


func _on_inventory_changed() -> void:
	_satchel_label.text = satchel_text()
	if _inventory_panel.visible:
		_rebuild_inventory()


func _rebuild_inventory() -> void:
	for child in _inventory_list.get_children():
		_inventory_list.remove_child(child)
		child.queue_free()
	_add_section("Satchel  %s" % satchel_text(), GameState.satchel)
	if GameState.location == &"tavern":
		_add_section("Pantry", GameState.pantry)


func _add_section(title: String, inventory: Inventory) -> void:
	var header := Label.new()
	header.text = title
	header.theme_type_variation = &"HeaderLabel"
	_inventory_list.add_child(header)
	if inventory.is_empty():
		var empty := Label.new()
		empty.text = "  (empty)"
		empty.theme_type_variation = &"MutedLabel"
		_inventory_list.add_child(empty)
		return
	var contents := inventory.items()
	var ids := contents.keys()
	ids.sort_custom(func(a: StringName, b: StringName) -> bool: return _name_of(a) < _name_of(b))
	for id: StringName in ids:
		_inventory_list.add_child(_item_row(id, contents[id]))


func _item_row(id: StringName, amount: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	var icon := TextureRect.new()
	var item := GameDB.item(id)
	icon.texture = item.icon if item != null else null
	icon.custom_minimum_size = Vector2(16, 16)
	row.add_child(icon)
	var name_label := Label.new()
	name_label.text = _name_of(id)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var count_label := Label.new()
	count_label.text = str(amount)
	row.add_child(count_label)
	return row


func _name_of(id: StringName) -> String:
	var item := GameDB.item(id)
	return item.display_name if item != null else String(id)


func _show_toast(text: String, icon: Texture2D) -> void:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	panel.add_child(row)
	if icon != null:
		var icon_rect := TextureRect.new()
		icon_rect.texture = icon
		row.add_child(icon_rect)
	var label := Label.new()
	label.text = text
	row.add_child(label)
	_toasts.add_child(panel)
	while _toasts.get_child_count() > MAX_TOASTS:
		var oldest := _toasts.get_child(0)
		_toasts.remove_child(oldest)
		oldest.queue_free()
	var tween := panel.create_tween()
	tween.tween_interval(TOAST_SECONDS)
	tween.tween_property(panel, "modulate:a", 0.0, 0.4)
	tween.tween_callback(panel.queue_free)
