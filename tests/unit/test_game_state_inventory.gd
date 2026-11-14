extends TestCase
## GameState owns one satchel and one pantry for the whole session.


func after_each() -> void:
	GameState.new_game()


func test_new_game_starts_with_empty_base_satchel_and_pantry() -> void:
	GameState.satchel.add(&"glowcap", 2)
	GameState.pantry.add(&"fernleaf", 9)
	GameState.new_game()
	assert_true(GameState.satchel.is_empty())
	assert_true(GameState.pantry.is_empty())
	assert_eq(GameState.satchel.capacity, GameState.BASE_SATCHEL_CAPACITY)
	assert_eq(GameState.pantry.capacity, Inventory.UNLIMITED)


func test_new_game_keeps_the_same_inventory_objects() -> void:
	# UI connects to these objects once; replacing them would silently disconnect it.
	var satchel := GameState.satchel
	var pantry := GameState.pantry
	var counter := GameState.counter
	GameState.new_game()
	assert_true(GameState.satchel == satchel)
	assert_true(GameState.pantry == pantry)
	assert_true(GameState.counter == counter)


func test_new_game_clears_the_serving_counter() -> void:
	GameState.counter.add(&"glowcap_soup", 2)
	GameState.new_game()
	assert_true(GameState.counter.is_empty())


func test_cook_draws_from_pantry_and_satchel_into_the_counter() -> void:
	GameState.new_game()
	GameState.pantry.add(&"glowcap", 1)
	GameState.satchel.add(&"glowcap", 1)
	GameState.satchel.add(&"fernleaf", 1)
	assert_true(GameState.cook(GameDB.recipe(&"glowcap_soup")))
	assert_true(GameState.pantry.is_empty())
	assert_true(GameState.satchel.is_empty())
	assert_eq(GameState.counter.items(), {&"glowcap_soup": 1})


func test_gather_records_node_state_against_play_time() -> void:
	GameState.new_game()
	GameState.advance_time(12.0)
	assert_eq(GameState.gather(&"forest:1,1", &"glowcap", 2, 60.0), 2)
	assert_eq(GameState.node_remaining(&"forest:1,1", 2, 60.0), 0)
	GameState.advance_time(60.0)
	assert_eq(GameState.node_remaining(&"forest:1,1", 2, 60.0), 2)


func test_new_game_regrows_every_node() -> void:
	GameState.gather(&"forest:1,1", &"glowcap", 2, 60.0)
	GameState.new_game()
	assert_eq(GameState.node_remaining(&"forest:1,1", 2, 60.0), 2)
