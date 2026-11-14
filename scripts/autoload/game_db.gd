extends Node
## Read-only registry of data definitions (autoload "GameDB"). Definitions are listed explicitly so
## exports never depend on directory scanning; tests verify their integrity.

const ITEMS := [
	preload("res://data/items/glowcap.tres"),
	preload("res://data/items/moonberry.tres"),
	preload("res://data/items/fernleaf.tres"),
	preload("res://data/items/sweetroot.tres"),
	preload("res://data/items/honeycomb.tres"),
	preload("res://data/items/glowcap_soup.tres"),
	preload("res://data/items/moonberry_tart.tres"),
	preload("res://data/items/hearthroot_stew.tres"),
]
const RECIPES := [
	preload("res://data/recipes/glowcap_soup.tres"),
	preload("res://data/recipes/moonberry_tart.tres"),
	preload("res://data/recipes/hearthroot_stew.tres"),
]

var _items := {}
var _recipes := {}


func _init() -> void:
	for item: ItemData in ITEMS:
		_items[item.id] = item
	for recipe: RecipeData in RECIPES:
		_recipes[recipe.id] = recipe


func item(id: StringName) -> ItemData:
	return _items.get(id)


func has_item(id: StringName) -> bool:
	return _items.has(id)


func all_items() -> Array[ItemData]:
	var out: Array[ItemData] = []
	out.assign(ITEMS)
	return out


func ingredients() -> Array[ItemData]:
	return all_items().filter(func(i: ItemData) -> bool: return i.kind == ItemData.Kind.INGREDIENT)


func recipe(id: StringName) -> RecipeData:
	return _recipes.get(id)


func recipes() -> Array[RecipeData]:
	var out: Array[RecipeData] = []
	out.assign(RECIPES)
	return out
