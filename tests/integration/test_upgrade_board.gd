extends GameSession
## Buying the Expanded Satchel at the tavern notice board.

var cost: int


func before_each() -> void:
	await super()
	cost = GameDB.upgrade(&"expanded_satchel").cost


func _open_board() -> UpgradePanel:
	await stand_before(main.current_world.get_node("UpgradeBoard"), 12.0)
	await press(&"interact")
	return main.upgrade_panel


func test_the_board_offers_the_expanded_satchel() -> void:
	var panel := await _open_board()
	assert_true(panel.visible)
	assert_false(main.player.input_enabled)
	assert_true(panel.listing_text().contains("Expanded Satchel"), panel.listing_text())
	assert_true(panel.listing_text().contains(str(cost)), panel.listing_text())


func test_buying_with_enough_coins_expands_the_satchel() -> void:
	GameState.earn(cost)
	var panel := await _open_board()
	assert_true(panel.buy(&"expanded_satchel"))
	assert_eq(GameState.coins, 0)
	assert_eq(main.hud.satchel_text(), "0/%d" % GameState.satchel.capacity)
	assert_true(GameState.satchel.capacity > GameState.BASE_SATCHEL_CAPACITY)
	assert_true(last_toast().contains(str(GameState.satchel.capacity)), last_toast())


func test_cannot_buy_without_enough_coins() -> void:
	GameState.earn(cost - 1)
	var panel := await _open_board()
	assert_false(panel.can_buy(&"expanded_satchel"))
	assert_false(panel.buy(&"expanded_satchel"))
	assert_eq(GameState.coins, cost - 1)


func test_closing_the_board_gives_control_back() -> void:
	var panel := await _open_board()
	await press(&"ui_cancel")
	assert_false(panel.visible)
	assert_true(main.player.input_enabled)


func test_the_bigger_satchel_carries_more_on_the_next_trip() -> void:
	GameState.earn(cost)
	var panel := await _open_board()
	panel.buy(&"expanded_satchel")
	await press(&"ui_cancel")
	GameState.satchel.add(&"fernleaf", GameState.BASE_SATCHEL_CAPACITY)
	await travel(&"forest", &"tavern_door")
	var node: GatherNode = null
	for candidate in nodes_of_type(func(n: Node) -> bool: return n is GatherNode):
		if candidate.item.id == &"glowcap":
			node = candidate
			break
	await stand_before(node)
	await press(&"interact")
	assert_eq(GameState.satchel.total(), GameState.BASE_SATCHEL_CAPACITY + node.max_yield,
			"gathering continues past the old limit")
