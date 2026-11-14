class_name SaveData
extends RefCounted
## Versioned save format (plain, JSON-friendly dictionaries) and the rules for applying one safely.
##
## Version history:
##   1 - first vertical-slice format.
##
## `apply` validates the version before touching anything, then sanitises every field: unknown items,
## upgrades and worlds are dropped, counts must be positive whole numbers, and coins are rebuilt from
## the earned/spent ledger if they disagree. Guests and the open sign are never saved: a loaded game
## always starts with the tavern closed.

const VERSION := 1
const WORLDS := [&"tavern", &"forest"]
const STAT_KEYS := ["coins_earned", "coins_spent", "dishes_served", "items_gathered",
		"ingredients_used", "dishes_cooked"]


static func capture(state: Node, player_position: Vector2) -> Dictionary:
	var nodes := {}
	for id: StringName in state.gather_nodes:
		nodes[String(id)] = state.gather_nodes[id].duplicate()
	var upgrades: Array[String] = []
	for id: StringName in state.owned_upgrades:
		upgrades.append(String(id))
	return {
		"version": VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"play_time": state.play_time,
		"location": String(state.location),
		"position": [player_position.x, player_position.y],
		"coins": state.coins,
		"satchel": state.satchel.to_dict(),
		"pantry": state.pantry.to_dict(),
		"counter": state.counter.to_dict(),
		"owned_upgrades": upgrades,
		"gather_nodes": nodes,
		"stats": state.stats.duplicate(),
	}


## Returns {"ok": true, "location": StringName, "position": Vector2 or null} or {"ok": false, "error": ...}.
static func apply(data: Dictionary, state: Node) -> Dictionary:
	var version: Variant = data.get("version")
	if not _is_whole_number(version):
		return _fail("This save has no valid version and cannot be loaded.")
	if int(version) > VERSION:
		return _fail("This save was made by a newer version of the game (save v%d)." % int(version))
	if int(version) < 1:
		return _fail("This save format (v%d) is not supported." % int(version))
	data = migrate(data, int(version))

	# Validation passed: from here on the save replaces the current session.
	state.new_game()
	state.play_time = maxf(0.0, _number(data.get("play_time"), 0.0))
	_load_inventory(state.satchel, data.get("satchel"))
	_load_inventory(state.pantry, data.get("pantry"))
	_load_inventory(state.counter, data.get("counter"))
	var upgrades: Variant = data.get("owned_upgrades")
	if upgrades is Array:
		for id: Variant in upgrades:
			if id is String and GameDB.upgrade(StringName(id)) != null:
				state.owned_upgrades[StringName(id)] = true
	state.satchel.set_capacity(state.satchel_capacity())
	var nodes: Variant = data.get("gather_nodes")
	if nodes is Dictionary:
		for key: Variant in nodes:
			var node_state: Variant = nodes[key]
			if node_state is Dictionary and _is_whole_number(node_state.get("remaining")) \
					and int(node_state["remaining"]) >= 0 and _is_number(node_state.get("depleted_at")):
				state.gather_nodes[StringName(str(key))] = {
					"remaining": int(node_state["remaining"]),
					"depleted_at": float(node_state["depleted_at"]),
				}
	var stats: Variant = data.get("stats")
	if stats is Dictionary:
		for key: String in STAT_KEYS:
			state.stats[key] = maxi(0, int(_number(stats.get(key), 0.0)))
	var ledger: int = state.stats["coins_earned"] - state.stats["coins_spent"]
	var coins := maxi(0, int(_number(data.get("coins"), 0.0)))
	state.coins = coins if coins == ledger else maxi(0, ledger)
	state.coins_changed.emit(state.coins)
	state.upgrades_changed.emit()

	var location := StringName(str(data.get("location", "tavern")))
	if not location in WORLDS:
		location = &"tavern"
	state.location = location
	var position: Variant = null
	var raw_position: Variant = data.get("position")
	if raw_position is Array and raw_position.size() == 2 and _is_number(raw_position[0]) \
			and _is_number(raw_position[1]):
		position = Vector2(raw_position[0], raw_position[1])
	return {"ok": true, "location": location, "position": position}


## Upgrades older save formats to VERSION. Only v1 exists so far.
static func migrate(data: Dictionary, _from_version: int) -> Dictionary:
	return data


static func _load_inventory(inventory: Inventory, raw: Variant) -> void:
	if not raw is Dictionary:
		return
	var known := {}
	for key: Variant in raw:
		if GameDB.has_item(StringName(str(key))):
			known[key] = raw[key]
	inventory.load_counts(known)


static func _is_number(value: Variant) -> bool:
	return value is int or value is float


static func _is_whole_number(value: Variant) -> bool:
	return _is_number(value) and floorf(value) == value


static func _number(value: Variant, fallback: float) -> float:
	return float(value) if _is_number(value) else fallback


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "error": message}
