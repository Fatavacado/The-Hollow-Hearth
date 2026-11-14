extends GameSession
## Cooking at the tavern hearth through the real cooking panel.


func _hearth() -> Node2D:
	return main.current_world.get_node("Actors/Hearth")


func _stock_soup_ingredients() -> void:
	GameState.pantry.add(&"glowcap", 2)
	GameState.satchel.add(&"fernleaf", 1)


func _open_panel() -> CookingPanel:
	await stand_before(_hearth(), 20.0)
	await press(&"interact")
	return main.cooking_panel


func test_interacting_with_the_hearth_opens_the_cooking_panel() -> void:
	var panel := await _open_panel()
	assert_true(panel.visible)
	assert_false(main.player.input_enabled, "player stays put while cooking")
	assert_eq(panel.recipe_count(), 3)


func test_recipes_without_ingredients_cannot_be_chosen() -> void:
	_stock_soup_ingredients()
	var panel := await _open_panel()
	assert_true(panel.is_recipe_available(&"glowcap_soup"))
	assert_false(panel.is_recipe_available(&"moonberry_tart"))
	assert_false(panel.choose(&"moonberry_tart"), "unavailable recipe refuses to start")
	assert_false(panel.is_cooking())


func test_cooking_a_recipe_consumes_ingredients_and_puts_the_dish_on_the_counter() -> void:
	_stock_soup_ingredients()
	var panel := await _open_panel()
	assert_true(panel.choose(&"glowcap_soup"))
	assert_true(panel.is_cooking())
	await wait_seconds(panel.cook_seconds() + 0.4)
	assert_false(panel.is_cooking())
	assert_eq(GameState.counter.count(&"glowcap_soup"), 1)
	assert_eq(GameState.pantry.count(&"glowcap"), 0)
	assert_eq(GameState.satchel.count(&"fernleaf"), 0)
	assert_true(last_toast().contains("Glowcap Soup"), "cook feedback: '%s'" % last_toast())


func test_ingredients_stay_untouched_until_the_dish_is_done() -> void:
	_stock_soup_ingredients()
	var panel := await _open_panel()
	panel.choose(&"glowcap_soup")
	await wait_seconds(0.2)
	assert_eq(GameState.pantry.count(&"glowcap"), 2, "nothing consumed mid-cook")


func test_cancelling_mid_cook_consumes_nothing() -> void:
	_stock_soup_ingredients()
	var panel := await _open_panel()
	panel.choose(&"glowcap_soup")
	await wait_seconds(0.2)
	await press(&"ui_cancel")
	assert_false(panel.is_cooking(), "cancel stops the cook")
	assert_true(panel.visible, "cancel returns to the recipe list")
	await wait_seconds(2.5)  # longer than any recipe takes
	assert_eq(GameState.counter.count(&"glowcap_soup"), 0)
	assert_eq(GameState.pantry.count(&"glowcap"), 2)
	assert_eq(GameState.satchel.count(&"fernleaf"), 1)


func test_stirring_with_interact_finishes_sooner() -> void:
	_stock_soup_ingredients()
	var panel := await _open_panel()
	panel.choose(&"glowcap_soup")
	for i in 4:
		await press(&"interact")
	await wait_seconds(panel.cook_seconds() * 0.45)
	assert_eq(GameState.counter.count(&"glowcap_soup"), 1, "four stirs cut the cook time by more than half")


func test_closing_the_panel_gives_control_back() -> void:
	var panel := await _open_panel()
	await press(&"ui_cancel")
	assert_false(panel.visible)
	assert_true(main.player.input_enabled)


func test_counter_shows_cooked_dishes() -> void:
	GameState.counter.add(&"glowcap_soup", 2)
	GameState.counter.add(&"moonberry_tart", 1)
	await wait_frames(2)
	var counter: Node = main.current_world.get_node("Actors/Counter")
	assert_eq(counter.shown_dish_count(), 3)
