extends TestCase
## Multi-inventory transactions: transfers and consumption across several sources.


func _inv(capacity: int, contents: Dictionary) -> Inventory:
	var inv := Inventory.new(capacity)
	for id: StringName in contents:
		inv.add(id, contents[id])
	return inv


func test_transfer_all_moves_every_item_and_preserves_totals() -> void:
	var satchel := _inv(10, {&"glowcap": 3, &"fernleaf": 2})
	var pantry := _inv(Inventory.UNLIMITED, {&"glowcap": 1})
	assert_eq(InventoryTransactions.transfer_all(satchel, pantry), 5)
	assert_true(satchel.is_empty())
	assert_eq(pantry.items(), {&"glowcap": 4, &"fernleaf": 2})


func test_transfer_all_into_limited_target_moves_only_what_fits() -> void:
	var from := _inv(10, {&"glowcap": 3, &"fernleaf": 2})
	var to := _inv(4, {})
	var moved := InventoryTransactions.transfer_all(from, to)
	assert_eq(moved, 4)
	assert_eq(from.total() + to.total(), 5, "nothing created or destroyed")


func test_available_sums_all_sources() -> void:
	var a := _inv(10, {&"glowcap": 2})
	var b := _inv(10, {&"glowcap": 3, &"fernleaf": 1})
	assert_eq(InventoryTransactions.available([a, b], &"glowcap"), 5)
	assert_eq(InventoryTransactions.available([a, b], &"honeycomb"), 0)


func test_consume_takes_from_earlier_sources_first() -> void:
	var pantry := _inv(Inventory.UNLIMITED, {&"glowcap": 1})
	var satchel := _inv(10, {&"glowcap": 3, &"fernleaf": 1})
	assert_true(InventoryTransactions.consume([pantry, satchel], {&"glowcap": 2, &"fernleaf": 1}))
	assert_eq(pantry.count(&"glowcap"), 0)
	assert_eq(satchel.count(&"glowcap"), 2)
	assert_eq(satchel.count(&"fernleaf"), 0)


func test_consume_is_all_or_nothing() -> void:
	var pantry := _inv(Inventory.UNLIMITED, {&"glowcap": 2})
	var satchel := _inv(10, {&"fernleaf": 1})
	assert_false(InventoryTransactions.consume([pantry, satchel], {&"glowcap": 2, &"honeycomb": 1}))
	assert_eq(pantry.count(&"glowcap"), 2, "nothing consumed when one requirement is missing")
	assert_eq(satchel.count(&"fernleaf"), 1)


func test_consume_rejects_non_positive_requirements() -> void:
	var satchel := _inv(10, {&"glowcap": 2})
	assert_false(InventoryTransactions.consume([satchel], {&"glowcap": 0}))
	assert_false(InventoryTransactions.consume([satchel], {&"glowcap": -1}))
	assert_eq(satchel.count(&"glowcap"), 2)
