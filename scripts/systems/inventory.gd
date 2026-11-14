class_name Inventory
extends RefCounted
## Item counts with an optional total-item capacity. This is the only place counts change:
## every mutation validates first and applies all-or-nothing (except `add_up_to`, which is
## explicitly partial). Counts never go negative and adds never exceed capacity.

signal changed

const UNLIMITED := -1

var capacity: int
var _counts: Dictionary = {}  # StringName -> int (> 0)


func _init(item_capacity: int = UNLIMITED) -> void:
	capacity = item_capacity


func count(id: StringName) -> int:
	return _counts.get(id, 0)


func total() -> int:
	var sum := 0
	for id: StringName in _counts:
		sum += _counts[id]
	return sum


func free_space() -> int:
	if capacity == UNLIMITED:
		return 1 << 30
	return maxi(0, capacity - total())


func is_empty() -> bool:
	return _counts.is_empty()


func has(id: StringName, amount: int) -> bool:
	return amount > 0 and count(id) >= amount


## Snapshot of the contents (id -> count). Mutating it does not affect the inventory.
func items() -> Dictionary:
	return _counts.duplicate()


func can_add(_id: StringName, amount: int) -> bool:
	return amount > 0 and amount <= free_space()


func add(id: StringName, amount: int) -> bool:
	if not can_add(id, amount):
		return false
	_counts[id] = count(id) + amount
	changed.emit()
	return true


## Adds as many as fit (up to `amount`) and returns how many were added.
func add_up_to(id: StringName, amount: int) -> int:
	var fits := mini(amount, free_space())
	if fits <= 0:
		return 0
	add(id, fits)
	return fits


func remove(id: StringName, amount: int) -> bool:
	if not has(id, amount):
		return false
	var left := count(id) - amount
	if left == 0:
		_counts.erase(id)
	else:
		_counts[id] = left
	changed.emit()
	return true


func set_capacity(new_capacity: int) -> void:
	capacity = new_capacity
	changed.emit()


## Plain, JSON-friendly form: { "item_id": count }.
func to_dict() -> Dictionary:
	var out := {}
	for id: StringName in _counts:
		out[String(id)] = _counts[id]
	return out


## Replaces the contents from `to_dict()` output. Entries that are not positive whole numbers are
## dropped. Capacity is not enforced here so a save can never silently destroy items.
func load_counts(data: Dictionary) -> void:
	_counts.clear()
	for key in data:
		var value: Variant = data[key]
		if not (value is int or value is float):
			continue
		if value <= 0 or floorf(value) != value:
			continue
		_counts[StringName(str(key))] = int(value)
	changed.emit()
