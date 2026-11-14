extends TestCase
## Data integrity of the definitions registered in GameDB.


func test_slice_has_exactly_five_ingredients() -> void:
	assert_eq(GameDB.ingredients().size(), 5)


func test_item_ids_are_unique_and_resolvable() -> void:
	var seen := {}
	for item in GameDB.all_items():
		assert_false(seen.has(item.id), "duplicate item id %s" % item.id)
		seen[item.id] = true
		assert_eq(GameDB.item(item.id), item)


func test_items_are_presentable() -> void:
	for item in GameDB.all_items():
		assert_false(item.display_name.is_empty(), "%s needs a display name" % item.id)
		assert_not_null(item.icon, "%s needs an icon" % item.id)


func test_unknown_ids_resolve_to_null() -> void:
	assert_null(GameDB.item(&"not_an_item"))
	assert_false(GameDB.has_item(&"not_an_item"))
