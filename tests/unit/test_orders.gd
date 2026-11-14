extends TestCase
## Which dishes a new guest may order, how guests choose, and what they pay.

var soup: RecipeData
var tart: RecipeData
var recipes: Array


func _recipe(id: StringName, ingredients: Dictionary[StringName, int], price: int) -> RecipeData:
	var r := RecipeData.new()
	r.id = id
	r.ingredients = ingredients
	r.output = ItemData.new()
	r.output.id = id
	r.output.kind = ItemData.Kind.DISH
	r.output.price = price
	return r


func _inv(contents: Dictionary) -> Inventory:
	var inv := Inventory.new(Inventory.UNLIMITED)
	for id: StringName in contents:
		inv.add(id, contents[id])
	return inv


func _ids(list: Array) -> Array:
	return list.map(func(r: RecipeData) -> StringName: return r.id)


func before_each() -> void:
	soup = _recipe(&"soup", {&"glowcap": 2, &"fernleaf": 1}, 10)
	tart = _recipe(&"tart", {&"moonberry": 2, &"sweetroot": 1}, 14)
	recipes = [soup, tart]


func test_dishes_on_the_counter_can_be_ordered() -> void:
	var options := Orders.orderable(recipes, _inv({&"tart": 1}), [_inv({})], [])
	assert_eq(_ids(options), [&"tart"])


func test_dishes_cookable_from_ingredients_can_be_ordered() -> void:
	var options := Orders.orderable(recipes, _inv({}), [_inv({&"glowcap": 2, &"fernleaf": 1})], [])
	assert_eq(_ids(options), [&"soup"])


func test_nothing_to_serve_means_nothing_to_order() -> void:
	assert_eq(Orders.orderable(recipes, _inv({}), [_inv({&"glowcap": 1})], []).size(), 0)


func test_pending_orders_reserve_counter_stock() -> void:
	var options := Orders.orderable(recipes, _inv({&"soup": 1}), [_inv({})], [&"soup"])
	assert_eq(options.size(), 0, "the only soup is already promised")


func test_pending_orders_reserve_ingredients() -> void:
	var sources := [_inv({&"glowcap": 3, &"fernleaf": 1})]
	assert_eq(_ids(Orders.orderable(recipes, _inv({}), sources, [])), [&"soup"])
	assert_eq(Orders.orderable(recipes, _inv({}), sources, [&"soup"]).size(), 0,
			"one soup's worth of ingredients is reserved for the waiting guest")


func test_pick_only_returns_orderable_dishes() -> void:
	var guest := GuestData.new()
	guest.favorite_dishes = [&"tart"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 50:
		assert_eq(Orders.pick(guest, [soup], rng), soup)
	assert_null(Orders.pick(guest, [], rng))


func test_guests_lean_towards_their_favourites() -> void:
	var guest := GuestData.new()
	guest.favorite_dishes = [&"tart"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var tarts := 0
	for i in 1000:
		if Orders.pick(guest, [soup, tart], rng) == tart:
			tarts += 1
	# favourites weigh 3 vs 1 -> about 75%
	assert_true(tarts > 680 and tarts < 820, "favourite picked %d / 1000" % tarts)


func test_next_guest_is_never_the_same_archetype_twice_in_a_row() -> void:
	var ghost := GuestData.new()
	ghost.id = &"ghost"
	var vampire := GuestData.new()
	vampire.id = &"vampire"
	var rng := RandomNumberGenerator.new()
	for seed_value in 50:
		rng.seed = seed_value
		assert_eq(Orders.choose_archetype([ghost, vampire], &"ghost", rng), vampire)
		assert_eq(Orders.choose_archetype([ghost, vampire], &"vampire", rng), ghost)


func test_first_guest_can_be_either_archetype() -> void:
	var ghost := GuestData.new()
	ghost.id = &"ghost"
	var vampire := GuestData.new()
	vampire.id = &"vampire"
	var rng := RandomNumberGenerator.new()
	var seen := {}
	for seed_value in 50:
		rng.seed = seed_value
		seen[Orders.choose_archetype([ghost, vampire], &"", rng).id] = true
	assert_eq(seen.size(), 2)


func test_favourite_dishes_earn_a_tip() -> void:
	var guest := GuestData.new()
	guest.favorite_dishes = [&"tart"]
	guest.tip = 5
	assert_eq(Orders.payment(guest, tart.output), 19)
	assert_eq(Orders.payment(guest, soup.output), 10)
