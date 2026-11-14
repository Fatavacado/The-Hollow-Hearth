extends GameSession
## Gathering in the real forest with the real interact input.


func before_each() -> void:
	await super()
	await travel(&"forest", &"tavern_door")


func _gather_nodes() -> Array:
	return nodes_of_type(func(n: Node) -> bool: return n is GatherNode)


func _first_node(item_id: StringName) -> GatherNode:
	for node: GatherNode in _gather_nodes():
		if node.item.id == item_id:
			return node
	return null


func _node_by_id(node_id: StringName) -> GatherNode:
	for node: GatherNode in _gather_nodes():
		if node.node_id == node_id:
			return node
	return null


func test_forest_offers_all_five_ingredients() -> void:
	var ids := {}
	for node: GatherNode in _gather_nodes():
		ids[node.item.id] = true
	assert_eq(ids.size(), 5, "ingredient types found: %s" % [ids.keys()])


func test_gather_node_ids_are_unique() -> void:
	var seen := {}
	for node: GatherNode in _gather_nodes():
		assert_false(seen.has(node.node_id), "duplicate node id %s" % node.node_id)
		seen[node.node_id] = true


func test_prompt_names_the_ingredient_in_front_of_the_player() -> void:
	await stand_before(_first_node(&"moonberry"))
	assert_true(main.hud.prompt_text().contains("Moonberry"), "prompt was '%s'" % main.hud.prompt_text())


func test_interacting_gathers_the_whole_yield_into_the_satchel() -> void:
	var node := _first_node(&"glowcap")
	await stand_before(node)
	await press(&"interact")
	assert_eq(GameState.satchel.count(&"glowcap"), node.max_yield)
	assert_eq(node.available(), 0)
	assert_eq(node.texture, node.empty_texture, "picked sprite shown")
	assert_true(last_toast().contains("Glowcap"), "pickup feedback: '%s'" % last_toast())


func test_full_satchel_leaves_ingredients_on_the_node() -> void:
	GameState.satchel.add(&"fernleaf", GameState.satchel.free_space())
	var node := _first_node(&"glowcap")
	await stand_before(node)
	await press(&"interact")
	assert_eq(GameState.satchel.count(&"glowcap"), 0)
	assert_eq(node.available(), node.max_yield)
	assert_true(last_toast().to_lower().contains("full"), "full-satchel feedback: '%s'" % last_toast())


func test_picked_node_stays_picked_after_leaving_and_returning() -> void:
	var node := _first_node(&"glowcap")
	var node_id := node.node_id
	await stand_before(node)
	await press(&"interact")
	await travel(&"tavern", &"entrance")
	await travel(&"forest", &"tavern_door")
	var again := _node_by_id(node_id)
	assert_not_null(again)
	assert_eq(again.available(), 0)
	assert_eq(again.texture, again.empty_texture)


func test_node_regrows_after_enough_play_time() -> void:
	var node := _first_node(&"glowcap")
	await stand_before(node)
	await press(&"interact")
	GameState.advance_time(node.regrow_seconds + 1.0)
	await wait_seconds(0.6)
	assert_eq(node.available(), node.max_yield)
	assert_eq(node.texture, node.full_texture)


func test_satchel_counter_tracks_gathering() -> void:
	var node := _first_node(&"moonberry")
	await stand_before(node)
	await press(&"interact")
	assert_eq(main.hud.satchel_text(), "%d/%d" % [node.max_yield, GameState.satchel.capacity])
