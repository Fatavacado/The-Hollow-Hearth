extends TestCase
## Versioned save data: capture, sanitise and apply GameState.


func before_each() -> void:
	GameState.new_game()


func after_each() -> void:
	GameState.new_game()


func _populated_state() -> void:
	GameState.advance_time(321.5)
	GameState.earn(90)
	GameState.buy_upgrade(GameDB.upgrade(&"expanded_satchel"))
	GameState.satchel.add(&"moonberry", 4)
	GameState.pantry.add(&"glowcap", 7)
	GameState.counter.add(&"glowcap_soup", 2)
	GameState.gather(&"forest:4,13", &"moonberry", 3, 120.0)
	GameState.record_served()
	GameState.location = &"forest"


func _round_trip(data: Dictionary) -> Dictionary:
	return JSON.parse_string(JSON.stringify(data))


func test_round_trip_restores_progress() -> void:
	_populated_state()
	var data := _round_trip(SaveData.capture(GameState, Vector2(512, 300)))
	GameState.new_game()
	var result := SaveData.apply(data, GameState)
	assert_true(result.ok, result.get("error", ""))
	assert_eq(GameState.coins, 30)
	assert_true(GameState.owns_upgrade(&"expanded_satchel"))
	assert_eq(GameState.satchel.capacity, 18, "capacity derived from owned upgrades")
	assert_eq(GameState.satchel.items(), {&"moonberry": 7})
	assert_eq(GameState.pantry.items(), {&"glowcap": 7})
	assert_eq(GameState.counter.items(), {&"glowcap_soup": 2})
	assert_eq(GameState.node_remaining(&"forest:4,13", 3, 120.0), 0, "picked node stays picked")
	assert_almost_eq(GameState.play_time, 321.5, 0.001)
	assert_eq(GameState.stats["dishes_served"], 1)
	assert_eq(GameState.stats["coins_earned"], 90)
	assert_eq(result.location, &"forest")
	assert_eq(result.position, Vector2(512, 300))


func test_saves_carry_the_current_version() -> void:
	assert_eq(SaveData.capture(GameState, Vector2.ZERO)["version"], SaveData.VERSION)


func test_loading_always_starts_with_the_tavern_closed() -> void:
	GameState.set_tavern_open(true)
	var data := _round_trip(SaveData.capture(GameState, Vector2.ZERO))
	GameState.new_game()
	SaveData.apply(data, GameState)
	assert_false(GameState.tavern_open)


func test_newer_save_versions_are_refused_without_touching_state() -> void:
	GameState.earn(5)
	var data := _round_trip(SaveData.capture(GameState, Vector2.ZERO))
	data["version"] = SaveData.VERSION + 1
	data["coins"] = 999
	var result := SaveData.apply(data, GameState)
	assert_false(result.ok)
	assert_eq(GameState.coins, 5)


func test_missing_or_malformed_version_is_refused() -> void:
	assert_false(SaveData.apply({"coins": 3}, GameState).ok)
	assert_false(SaveData.apply({"version": "one"}, GameState).ok)


func test_invalid_values_are_sanitised() -> void:
	var data := _round_trip(SaveData.capture(GameState, Vector2.ZERO))
	data["coins"] = -40
	data["satchel"] = {"glowcap": 2, "not_an_item": 5, "fernleaf": -1}
	data["owned_upgrades"] = ["expanded_satchel", "rocket_boots"]
	data["location"] = "the_moon"
	data["position"] = ["x", 3]
	data["gather_nodes"] = {"forest:1,1": {"remaining": -2, "depleted_at": 5.0}, "bad": 7}
	var result := SaveData.apply(data, GameState)
	assert_true(result.ok)
	assert_eq(GameState.coins, 0)
	assert_eq(GameState.satchel.items(), {&"glowcap": 2})
	assert_eq(GameState.owned_upgrades.keys(), [&"expanded_satchel"])
	assert_eq(result.location, &"tavern")
	assert_null(result.position)
	assert_true(GameState.gather_nodes.is_empty(), "malformed node states dropped")


func test_coin_ledger_stays_consistent_after_loading() -> void:
	_populated_state()
	var data := _round_trip(SaveData.capture(GameState, Vector2.ZERO))
	data["coins"] = 12345  # tampered or corrupted
	SaveData.apply(data, GameState)
	assert_eq(GameState.coins, GameState.stats["coins_earned"] - GameState.stats["coins_spent"],
			"coins are rebuilt from the ledger when they disagree")
