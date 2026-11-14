extends TestCase
## Integrity of the slice's recipes and dishes.


func test_slice_has_exactly_three_recipes() -> void:
	assert_eq(GameDB.recipes().size(), 3)


func test_recipes_use_known_ingredients_in_positive_amounts() -> void:
	for recipe in GameDB.recipes():
		assert_false(recipe.ingredients.is_empty(), "%s has ingredients" % recipe.id)
		for id: StringName in recipe.ingredients:
			var item := GameDB.item(id)
			assert_not_null(item, "%s uses unknown item %s" % [recipe.id, id])
			if item != null:
				assert_eq(item.kind, ItemData.Kind.INGREDIENT, "%s: %s must be an ingredient" % [recipe.id, id])
			assert_true(recipe.ingredients[id] > 0, "%s: amount of %s" % [recipe.id, id])


func test_recipes_produce_registered_priced_dishes() -> void:
	for recipe in GameDB.recipes():
		assert_not_null(recipe.output, "%s has an output" % recipe.id)
		assert_eq(GameDB.item(recipe.output.id), recipe.output, "%s output is registered" % recipe.id)
		assert_eq(recipe.output.kind, ItemData.Kind.DISH)
		assert_true(recipe.output.price > 0, "%s dish has a price" % recipe.id)


func test_every_ingredient_is_used_by_some_recipe() -> void:
	var used := {}
	for recipe in GameDB.recipes():
		for id: StringName in recipe.ingredients:
			used[id] = true
	for item in GameDB.ingredients():
		assert_true(used.has(item.id), "%s is gathered but never cooked" % item.id)


func test_recipe_ids_are_unique_and_resolvable() -> void:
	var seen := {}
	for recipe in GameDB.recipes():
		assert_false(seen.has(recipe.id))
		seen[recipe.id] = true
		assert_eq(GameDB.recipe(recipe.id), recipe)
