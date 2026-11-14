extends Node
## Read-only registry of data definitions (autoload "GameDB"). Definitions are listed explicitly so
## exports never depend on directory scanning; tests verify their integrity.

const ITEMS := [
	preload("res://data/items/glowcap.tres"),
	preload("res://data/items/moonberry.tres"),
	preload("res://data/items/fernleaf.tres"),
	preload("res://data/items/sweetroot.tres"),
	preload("res://data/items/honeycomb.tres"),
]

var _items := {}


func _init() -> void:
	for item: ItemData in ITEMS:
		_items[item.id] = item


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
