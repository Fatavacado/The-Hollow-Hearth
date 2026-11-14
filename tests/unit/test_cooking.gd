extends TestCase
## Cooking rules: atomic consume-and-produce across pantry and satchel.

var soup: RecipeData


func before_each() -> void:
	soup = RecipeData.new()
	soup.id = &"test_soup"
	soup.ingredients = {&"glowcap": 2, &"fernleaf": 1}
	soup.output = ItemData.new()
	soup.output.id = &"test_soup_dish"
	soup.output.kind = ItemData.Kind.DISH


func _inv(contents: Dictionary, capacity: int = Inventory.UNLIMITED) -> Inventory:
	var inv := Inventory.new(capacity)
	for id: StringName in contents:
		inv.add(id, contents[id])
	return inv


func test_cooking_consumes_exact_ingredients_and_adds_one_dish() -> void:
	var pantry := _inv({&"glowcap": 3, &"fernleaf": 1, &"moonberry": 2})
	var counter := _inv({})
	assert_true(Cooking.cook(soup, [pantry], counter))
	assert_eq(pantry.items(), {&"glowcap": 1, &"moonberry": 2})
	assert_eq(counter.items(), {&"test_soup_dish": 1})


func test_cooking_uses_the_pantry_before_the_satchel() -> void:
	var pantry := _inv({&"glowcap": 1})
	var satchel := _inv({&"glowcap": 2, &"fernleaf": 1}, 10)
	assert_true(Cooking.cook(soup, [pantry, satchel], _inv({})))
	assert_eq(pantry.count(&"glowcap"), 0)
	assert_eq(satchel.count(&"glowcap"), 1)


func test_missing_ingredient_cooks_nothing_and_consumes_nothing() -> void:
	var pantry := _inv({&"glowcap": 5})
	var counter := _inv({})
	assert_false(Cooking.cook(soup, [pantry], counter))
	assert_eq(pantry.count(&"glowcap"), 5)
	assert_true(counter.is_empty())


func test_full_counter_cooks_nothing_and_consumes_nothing() -> void:
	var pantry := _inv({&"glowcap": 2, &"fernleaf": 1})
	var counter := _inv({&"other": 1}, 1)
	assert_false(Cooking.cook(soup, [pantry], counter))
	assert_eq(pantry.items(), {&"glowcap": 2, &"fernleaf": 1})


func test_portions_are_limited_by_the_scarcest_ingredient() -> void:
	var pantry := _inv({&"glowcap": 7})
	var satchel := _inv({&"fernleaf": 2}, 10)
	assert_eq(Cooking.max_portions(soup, [pantry, satchel]), 2)
	assert_eq(Cooking.max_portions(soup, [_inv({&"glowcap": 1, &"fernleaf": 3})]), 0)


func test_missing_reports_each_shortfall() -> void:
	var pantry := _inv({&"glowcap": 1})
	assert_eq(Cooking.missing(soup, [pantry]), {&"glowcap": 1, &"fernleaf": 1})
	assert_eq(Cooking.missing(soup, [_inv({&"glowcap": 2, &"fernleaf": 1})]), {})
