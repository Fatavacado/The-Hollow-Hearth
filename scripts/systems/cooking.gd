class_name Cooking
extends RefCounted
## Cooking rules. `cook` is one atomic transaction: it validates every ingredient and the output
## slot first, then consumes from `sources` in order and adds exactly one dish.


static func can_cook(recipe: RecipeData, sources: Array) -> bool:
	return InventoryTransactions.can_consume(sources, recipe.ingredients)


## Item id -> how many more of it the recipe needs. Empty when cookable.
static func missing(recipe: RecipeData, sources: Array) -> Dictionary:
	var out := {}
	for id: StringName in recipe.ingredients:
		var short: int = recipe.ingredients[id] - InventoryTransactions.available(sources, id)
		if short > 0:
			out[id] = short
	return out


static func max_portions(recipe: RecipeData, sources: Array) -> int:
	var portions := 1 << 30
	for id: StringName in recipe.ingredients:
		portions = mini(portions, InventoryTransactions.available(sources, id) / recipe.ingredients[id])
	return portions if not recipe.ingredients.is_empty() else 0


static func cook(recipe: RecipeData, sources: Array, counter: Inventory) -> bool:
	if not can_cook(recipe, sources) or not counter.can_add(recipe.output.id, 1):
		return false
	InventoryTransactions.consume(sources, recipe.ingredients)
	counter.add(recipe.output.id, 1)
	return true
