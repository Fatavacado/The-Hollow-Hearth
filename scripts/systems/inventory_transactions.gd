class_name InventoryTransactions
extends RefCounted
## Operations spanning several inventories. Each validates completely before changing anything.


## Moves everything from `from` into `to` (as much as fits per item). Returns the number moved.
static func transfer_all(from: Inventory, to: Inventory) -> int:
	var moved := 0
	var contents := from.items()
	for id: StringName in contents:
		var added := to.add_up_to(id, contents[id])
		if added > 0:
			from.remove(id, added)
			moved += added
	return moved


static func available(sources: Array, id: StringName) -> int:
	var sum := 0
	for inv: Inventory in sources:
		sum += inv.count(id)
	return sum


static func can_consume(sources: Array, requirements: Dictionary) -> bool:
	if requirements.is_empty():
		return false
	for id: StringName in requirements:
		var need: int = requirements[id]
		if need <= 0 or available(sources, id) < need:
			return false
	return true


## Removes `requirements` (id -> amount) drawing from `sources` in order. All-or-nothing.
static func consume(sources: Array, requirements: Dictionary) -> bool:
	if not can_consume(sources, requirements):
		return false
	for id: StringName in requirements:
		var need: int = requirements[id]
		for inv: Inventory in sources:
			if need == 0:
				break
			var take := mini(need, inv.count(id))
			if take > 0:
				inv.remove(id, take)
				need -= take
	return true
