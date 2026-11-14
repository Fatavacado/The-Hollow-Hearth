extends TestCase
## Inventory model: the only place item counts change. All-or-nothing unless stated.

var changes := 0


func _tracked(capacity: int) -> Inventory:
	var inv := Inventory.new(capacity)
	inv.changed.connect(func() -> void: changes += 1)
	changes = 0
	return inv


func test_add_within_capacity_is_counted() -> void:
	var inv := _tracked(10)
	assert_true(inv.add(&"glowcap", 3))
	assert_true(inv.add(&"fernleaf", 2))
	assert_eq(inv.count(&"glowcap"), 3)
	assert_eq(inv.total(), 5)
	assert_eq(inv.free_space(), 5)


func test_add_beyond_capacity_fails_without_changes() -> void:
	var inv := _tracked(4)
	inv.add(&"glowcap", 3)
	assert_false(inv.add(&"fernleaf", 2))
	assert_eq(inv.count(&"fernleaf"), 0)
	assert_eq(inv.total(), 3)
	assert_eq(changes, 1, "only the successful add notifies")


func test_add_up_to_takes_only_what_fits() -> void:
	var inv := _tracked(5)
	inv.add(&"glowcap", 4)
	assert_eq(inv.add_up_to(&"moonberry", 3), 1)
	assert_eq(inv.count(&"moonberry"), 1)
	assert_eq(inv.add_up_to(&"moonberry", 3), 0, "full satchel takes nothing")
	assert_eq(inv.total(), 5)


func test_remove_more_than_held_fails_without_changes() -> void:
	var inv := _tracked(10)
	inv.add(&"glowcap", 2)
	assert_false(inv.remove(&"glowcap", 3))
	assert_eq(inv.count(&"glowcap"), 2)
	assert_eq(changes, 1)


func test_removing_everything_drops_the_entry() -> void:
	var inv := _tracked(10)
	inv.add(&"glowcap", 2)
	assert_true(inv.remove(&"glowcap", 2))
	assert_eq(inv.count(&"glowcap"), 0)
	assert_false(inv.items().has(&"glowcap"))
	assert_true(inv.is_empty())


func test_zero_and_negative_amounts_are_rejected() -> void:
	var inv := _tracked(10)
	inv.add(&"glowcap", 2)
	assert_false(inv.add(&"glowcap", 0))
	assert_false(inv.add(&"glowcap", -5))
	assert_false(inv.remove(&"glowcap", -1))
	assert_eq(inv.add_up_to(&"glowcap", -2), 0)
	assert_eq(inv.count(&"glowcap"), 2)
	assert_eq(changes, 1)


func test_unlimited_capacity_accepts_any_amount() -> void:
	var inv := Inventory.new(Inventory.UNLIMITED)
	assert_true(inv.add(&"glowcap", 5000))
	assert_eq(inv.count(&"glowcap"), 5000)


func test_raising_capacity_makes_room() -> void:
	var inv := _tracked(2)
	inv.add(&"glowcap", 2)
	assert_false(inv.can_add(&"glowcap", 1))
	inv.set_capacity(5)
	assert_true(inv.add(&"glowcap", 3))
	assert_eq(inv.total(), 5)


func test_items_returns_a_copy() -> void:
	var inv := Inventory.new(10)
	inv.add(&"glowcap", 2)
	var snapshot := inv.items()
	snapshot[&"glowcap"] = 99
	assert_eq(inv.count(&"glowcap"), 2)


func test_serialization_round_trip() -> void:
	var inv := Inventory.new(10)
	inv.add(&"glowcap", 2)
	inv.add(&"moonberry", 1)
	var restored := Inventory.new(10)
	restored.load_counts(inv.to_dict())
	assert_eq(restored.items(), {&"glowcap": 2, &"moonberry": 1})


func test_loading_counts_drops_invalid_entries() -> void:
	var inv := Inventory.new(10)
	inv.load_counts({"glowcap": 2, "fernleaf": -3, "moonberry": 0, "honeycomb": "x"})
	assert_eq(inv.items(), {&"glowcap": 2})
