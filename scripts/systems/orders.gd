class_name Orders
extends RefCounted
## Guest ordering rules. A guest only orders a dish the keeper can actually provide: one waiting on
## the counter, or one cookable from current ingredients after reserving what earlier, still unserved
## orders will need. Favourite dishes are FAVORITE_WEIGHT times as likely and earn the guest's tip.

const FAVORITE_WEIGHT := 3


## `pending` holds the dish ids already promised to waiting guests.
static func orderable(recipes: Array, counter: Inventory, sources: Array, pending: Array) -> Array[RecipeData]:
	var stock := counter.items()
	var pool := {}
	for inv: Inventory in sources:
		var contents := inv.items()
		for id: StringName in contents:
			pool[id] = pool.get(id, 0) + contents[id]
	for dish_id: StringName in pending:
		if stock.get(dish_id, 0) > 0:
			stock[dish_id] -= 1
			continue
		var recipe := _recipe_for(recipes, dish_id)
		if recipe != null:
			for id: StringName in recipe.ingredients:
				pool[id] = maxi(0, pool.get(id, 0) - recipe.ingredients[id])
	var out: Array[RecipeData] = []
	for recipe: RecipeData in recipes:
		if stock.get(recipe.output.id, 0) > 0 or _covers(pool, recipe.ingredients):
			out.append(recipe)
	return out


static func pick(guest: GuestData, options: Array, rng: RandomNumberGenerator) -> RecipeData:
	if options.is_empty():
		return null
	var total := 0
	for recipe: RecipeData in options:
		total += _weight(guest, recipe)
	var roll := rng.randi_range(1, total)
	for recipe: RecipeData in options:
		roll -= _weight(guest, recipe)
		if roll <= 0:
			return recipe
	return options[-1]


## The next visitor: random, but never the same archetype twice in a row when another exists, so
## every archetype keeps visiting.
static func choose_archetype(archetypes: Array, previous_id: StringName,
		rng: RandomNumberGenerator) -> GuestData:
	var options := archetypes.filter(func(g: GuestData) -> bool: return g.id != previous_id)
	if options.is_empty():
		options = archetypes
	return options[rng.randi() % options.size()]


static func is_favorite(guest: GuestData, dish: ItemData) -> bool:
	return dish.id in guest.favorite_dishes


static func payment(guest: GuestData, dish: ItemData) -> int:
	return dish.price + (guest.tip if is_favorite(guest, dish) else 0)


static func _weight(guest: GuestData, recipe: RecipeData) -> int:
	return FAVORITE_WEIGHT if is_favorite(guest, recipe.output) else 1


static func _covers(pool: Dictionary, needs: Dictionary) -> bool:
	for id: StringName in needs:
		if pool.get(id, 0) < needs[id]:
			return false
	return true


static func _recipe_for(recipes: Array, dish_id: StringName) -> RecipeData:
	for recipe: RecipeData in recipes:
		if recipe.output.id == dish_id:
			return recipe
	return null
