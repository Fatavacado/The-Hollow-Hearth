extends GameSession
## Tavern pantry: storing the satchel's contents.


func _pantry() -> Node2D:
	return main.current_world.get_node("Actors/Pantry")


func test_storing_moves_the_whole_satchel_into_the_pantry() -> void:
	GameState.satchel.add(&"glowcap", 3)
	GameState.satchel.add(&"fernleaf", 2)
	await stand_before(_pantry())
	await press(&"interact")
	assert_true(GameState.satchel.is_empty())
	assert_eq(GameState.pantry.items(), {&"glowcap": 3, &"fernleaf": 2})
	assert_true(last_toast().contains("5"), "store feedback: '%s'" % last_toast())


func test_storing_with_an_empty_satchel_changes_nothing() -> void:
	GameState.pantry.add(&"glowcap", 1)
	await stand_before(_pantry())
	await press(&"interact")
	assert_eq(GameState.pantry.items(), {&"glowcap": 1})
	assert_true(last_toast().to_lower().contains("empty"), "empty feedback: '%s'" % last_toast())


func test_inventory_panel_lists_satchel_and_pantry() -> void:
	GameState.satchel.add(&"moonberry", 2)
	GameState.pantry.add(&"sweetroot", 4)
	await press(&"inventory")
	assert_true(main.hud.inventory_visible())
	var text := main.hud.inventory_text()
	assert_true(text.contains("Moonberry") and text.contains("2"), text)
	assert_true(text.contains("Sweetroot") and text.contains("4"), text)
	await press(&"inventory")
	assert_false(main.hud.inventory_visible())
