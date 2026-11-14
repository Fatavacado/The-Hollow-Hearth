extends TestCase
## Session ledgers that make item and dish conservation checkable:
##   ingredients held (satchel + pantry) == gathered - used by cooking
##   dishes on the counter              == cooked - served


func before_each() -> void:
	GameState.new_game()


func after_each() -> void:
	GameState.new_game()


func test_gathering_records_items_gathered() -> void:
	GameState.gather(&"forest:1,1", &"glowcap", 2, 60.0)
	GameState.gather(&"forest:2,2", &"fernleaf", 2, 60.0)
	assert_eq(GameState.stats["items_gathered"], 4)


func test_cooking_records_ingredients_used_and_dishes_cooked() -> void:
	GameState.pantry.add(&"glowcap", 2)
	GameState.pantry.add(&"fernleaf", 1)
	assert_true(GameState.cook(GameDB.recipe(&"glowcap_soup")))
	assert_eq(GameState.stats["ingredients_used"], 3)
	assert_eq(GameState.stats["dishes_cooked"], 1)


func test_failed_cooking_records_nothing() -> void:
	GameState.pantry.add(&"glowcap", 1)
	assert_false(GameState.cook(GameDB.recipe(&"glowcap_soup")))
	assert_eq(GameState.stats["ingredients_used"], 0)
	assert_eq(GameState.stats["dishes_cooked"], 0)


func test_ledgers_survive_a_save_round_trip() -> void:
	GameState.gather(&"forest:1,1", &"glowcap", 2, 60.0)
	GameState.satchel.add(&"fernleaf", 1)  # direct add, outside the ledger
	GameState.cook(GameDB.recipe(&"glowcap_soup"))
	var data: Dictionary = JSON.parse_string(JSON.stringify(SaveData.capture(GameState, Vector2.ZERO)))
	GameState.new_game()
	SaveData.apply(data, GameState)
	assert_eq(GameState.stats["items_gathered"], 2)
	assert_eq(GameState.stats["ingredients_used"], 3)
	assert_eq(GameState.stats["dishes_cooked"], 1)
