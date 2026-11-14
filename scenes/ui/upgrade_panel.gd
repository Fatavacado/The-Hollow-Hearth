class_name UpgradePanel
extends PanelContainer
## Notice-board shop: lists upgrades with cost and a Buy button (disabled when owned or unaffordable).

signal closed

@onready var _list: VBoxContainer = %UpgradeList
@onready var _coins: Label = %CoinsLabel


func _ready() -> void:
	hide()
	GameState.coins_changed.connect(func(_c: int) -> void: _refresh_if_open())
	GameState.upgrades_changed.connect(_refresh_if_open)


func open() -> void:
	show()
	_rebuild()


func close() -> void:
	hide()
	closed.emit()


func can_buy(upgrade_id: StringName) -> bool:
	var upgrade := GameDB.upgrade(upgrade_id)
	return upgrade != null and not GameState.owns_upgrade(upgrade_id) and GameState.coins >= upgrade.cost


func buy(upgrade_id: StringName) -> bool:
	var upgrade := GameDB.upgrade(upgrade_id)
	if not can_buy(upgrade_id) or not GameState.buy_upgrade(upgrade):
		return false
	Feedback.toast("%s bought! Your satchel now holds %d ingredients." % [upgrade.display_name,
			GameState.satchel.capacity], upgrade.icon)
	_rebuild()
	return true


func listing_text() -> String:
	var parts: PackedStringArray = []
	for label in _list.find_children("*", "Label", true, false):
		parts.append((label as Label).text)
	return " ".join(parts)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"interact"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused is Button and is_ancestor_of(focused) and not (focused as Button).disabled:
			(focused as Button).pressed.emit()
		get_viewport().set_input_as_handled()


func _refresh_if_open() -> void:
	if visible:
		_rebuild()


func _rebuild() -> void:
	_coins.text = "You have %d coins" % GameState.coins
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	var first_button: Button = null
	for upgrade in GameDB.upgrades():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var icon := TextureRect.new()
		icon.texture = upgrade.icon
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		row.add_child(icon)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := Label.new()
		title.text = "%s  -  %d coins" % [upgrade.display_name, upgrade.cost]
		info.add_child(title)
		var description := Label.new()
		description.text = upgrade.description
		description.theme_type_variation = &"MutedLabel"
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.custom_minimum_size = Vector2(180, 0)
		info.add_child(description)
		row.add_child(info)
		var button := Button.new()
		var owned := GameState.owns_upgrade(upgrade.id)
		button.text = "Owned" if owned else "Buy"
		button.disabled = not can_buy(upgrade.id)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(buy.bind(upgrade.id))
		row.add_child(button)
		_list.add_child(row)
		if first_button == null and not button.disabled:
			first_button = button
	if first_button != null:
		first_button.grab_focus()
