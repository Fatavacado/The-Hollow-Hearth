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
const GUESTS := [
	preload("res://data/guests/lantern_ghost.tres"),
	preload("res://data/guests/velvet_vampire.tres"),
]
const UPGRADES := [
	preload("res://data/upgrades/expanded_satchel.tres"),
]

var _items := {}
var _recipes := {}
var _upgrades := {}


func _init() -> void:
	for item: ItemData in ITEMS:
		_items[item.id] = item
	for recipe: RecipeData in RECIPES:
		_recipes[recipe.id] = recipe
	for upgrade: UpgradeData in UPGRADES:
		_upgrades[upgrade.id] = upgrade


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


func guests() -> Array[GuestData]:
	var out: Array[GuestData] = []
	out.assign(GUESTS)
	return out


func upgrade(id: StringName) -> UpgradeData:
	return _upgrades.get(id)


func upgrades() -> Array[UpgradeData]:
	var out: Array[UpgradeData] = []
	out.assign(UPGRADES)
	return out
