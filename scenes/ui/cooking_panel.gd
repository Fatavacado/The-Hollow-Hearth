class_name CookingPanel
extends PanelContainer
## Hearth cooking UI. Pick a recipe (each ingredient shown as have/need), then a short cook fills
## on its own; tapping interact stirs it faster (optional). Ingredients are only consumed, in one
## transaction, when the dish is done — stopping early costs nothing.

signal closed

## Progress added by one stir (a full cook is 1.0).
const STIR_BOOST := 0.15

var _recipe: RecipeData
var _progress := 0.0
var _cooking := false
var _last_cook_seconds := 0.0
var _buttons := {}  # recipe id -> Button

@onready var _list: VBoxContainer = %RecipeList
@onready var _cook_box: VBoxContainer = %CookBox
@onready var _cook_label: Label = %CookLabel
@onready var _bar: ProgressBar = %CookProgress
@onready var _footer: Label = %Footer


func _ready() -> void:
	hide()
	GameState.pantry.changed.connect(_refresh_if_choosing)
	GameState.satchel.changed.connect(_refresh_if_choosing)


func open() -> void:
	show()
	_show_recipes()


func close() -> void:
	if _cooking:
		_stop()
	hide()
	closed.emit()


func recipe_count() -> int:
	return GameDB.recipes().size()


func is_recipe_available(recipe_id: StringName) -> bool:
	var recipe := GameDB.recipe(recipe_id)
	return recipe != null and Cooking.can_cook(recipe, GameState.cooking_sources())


func is_cooking() -> bool:
	return _cooking


## Cook time of the most recently chosen recipe.
func cook_seconds() -> float:
	return _last_cook_seconds


func choose(recipe_id: StringName) -> bool:
	if _cooking or not is_recipe_available(recipe_id):
		return false
	_recipe = GameDB.recipe(recipe_id)
	_progress = 0.0
	_last_cook_seconds = _recipe.cook_seconds
	_cooking = true
	_bar.value = 0.0
	_cook_label.text = "Cooking %s..." % _recipe.output.display_name
	_list.hide()
	_cook_box.show()
	_footer.text = "[E] Stir to cook faster      [Esc] Stop"
	Feedback.set_cooking(true)
	return true


func stir() -> void:
	if not _cooking:
		return
	_progress += STIR_BOOST
	var tween := create_tween()
	_bar.scale = Vector2(1.0, 1.25)
	tween.tween_property(_bar, "scale", Vector2.ONE, 0.12)


func _process(delta: float) -> void:
	if not _cooking:
		return
	_progress += delta / _recipe.cook_seconds
	_bar.value = clampf(_progress, 0.0, 1.0) * 100.0
	if _progress >= 1.0:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		if _cooking:
			_stop()
			_show_recipes()
		else:
			close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"interact"):
		if _cooking:
			stir()
		else:
			var focused := get_viewport().gui_get_focus_owner()
			if focused is Button and is_ancestor_of(focused) and not (focused as Button).disabled:
				(focused as Button).pressed.emit()
		get_viewport().set_input_as_handled()


func _finish() -> void:
	var recipe := _recipe
	_stop()
	if GameState.cook(recipe):
		Feedback.toast("Cooked %s! It's on the counter." % recipe.output.display_name, recipe.output.icon)
	else:
		Feedback.toast("The ingredients for %s are gone." % recipe.output.display_name)
	_show_recipes()


func _stop() -> void:
	_cooking = false
	_recipe = null
	Feedback.set_cooking(false)


func _show_recipes() -> void:
	_cook_box.hide()
	_list.show()
	_rebuild()
	var any_available := false
	for recipe in GameDB.recipes():
		var button: Button = _buttons[recipe.id]
		if not button.disabled:
			button.grab_focus()
			any_available = true
			break
	_footer.text = "[E] Cook      [Esc] Close" if any_available else "Gather ingredients in the forest.      [Esc] Close"


func _refresh_if_choosing() -> void:
	if visible and not _cooking:
		_show_recipes()


func _rebuild() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_buttons.clear()
	for recipe in GameDB.recipes():
		_list.add_child(_recipe_row(recipe))


func _recipe_row(recipe: RecipeData) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var icon := TextureRect.new()
	icon.texture = recipe.output.icon
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	row.add_child(icon)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 0)
	var title := Label.new()
	title.text = "%s  -  %d coins" % [recipe.output.display_name, recipe.output.price]
	info.add_child(title)
	var needs := HBoxContainer.new()
	needs.add_theme_constant_override("separation", 6)
	var sources := GameState.cooking_sources()
	for id: StringName in recipe.ingredients:
		var chip := HBoxContainer.new()
		chip.add_theme_constant_override("separation", 1)
		var chip_icon := TextureRect.new()
		chip_icon.texture = GameDB.item(id).icon
		chip.add_child(chip_icon)
		var have := InventoryTransactions.available(sources, id)
		var need: int = recipe.ingredients[id]
		var amount := Label.new()
		amount.text = "%d/%d" % [mini(have, 99), need]
		amount.theme_type_variation = &"GoodLabel" if have >= need else &"BadLabel"
		chip.add_child(amount)
		needs.add_child(chip)
	info.add_child(needs)
	row.add_child(info)
	var button := Button.new()
	button.text = "Cook"
	button.disabled = not Cooking.can_cook(recipe, sources)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(choose.bind(recipe.id))
	row.add_child(button)
	_buttons[recipe.id] = button
	return row
