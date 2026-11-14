class_name PlaytestAgent
extends Node
## Plays the vertical slice like an efficient player, through the real Main scene and the same
## inputs a player uses: movement actions, the interact action, menu buttons and Esc.
##
## walk = true  -> real movement: A* over cells probed against the world's physics, steering the
##                 move_* actions (honest timing for a full session).
## walk = false -> teleports between targets (fast regression test); interactions stay real.
##
## After every step it checks the conservation ledgers kept by GameState.

signal timeline_entry_logged(entry: Dictionary)

const NAV_CELL := 16
const MOVE_ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down"]
const SATCHEL_UPGRADE := &"expanded_satchel"
## Where to stand relative to an interactable, tried in order of path cost.
const STAND_OFFSETS := [Vector2(0, 22), Vector2(-24, 6), Vector2(24, 6), Vector2(0, -26)]

var main: Main
var walk := true
## Pause before each interaction, like a player reading the prompt.
var think_seconds := 0.4
var timeline: Array[Dictionary] = []
var problems: PackedStringArray = []

var _nav: AStarGrid2D
var _nav_world: World
var _skipped_nodes := {}


# ------------------------------------------------------------------ session
func run_session(post_upgrade_trips: int = 1) -> Dictionary:
	var started_ms := Time.get_ticks_msec()
	log_event("start: new game in the tavern")
	var trips: Array[Dictionary] = []
	var upgrade := GameDB.upgrade(SATCHEL_UPGRADE)
	var bought_at := -1.0
	while not GameState.owns_upgrade(SATCHEL_UPGRADE) and trips.size() < 5:
		trips.append(await loop_once(trips.size() + 1))
		if GameState.coins >= upgrade.cost and await buy_upgrade():
			bought_at = GameState.play_time
	for i in post_upgrade_trips:
		trips.append(await loop_once(trips.size() + 1))
	var reload_ok := await save_quit_and_continue()
	check("end of session")
	var after_upgrade: Dictionary = trips[-1] if GameState.owns_upgrade(SATCHEL_UPGRADE) else {}
	return {
		"ok": problems.is_empty(),
		"play_seconds": GameState.play_time,
		"real_seconds": (Time.get_ticks_msec() - started_ms) / 1000.0,
		"trips": trips,
		"upgrade_bought_at": bought_at,
		"gathered_after_upgrade": after_upgrade.get("gathered", 0),
		"reload_ok": reload_ok,
		"stats": GameState.stats.duplicate(),
		"coins": GameState.coins,
		"problems": problems,
		"timeline": timeline,
	}


func loop_once(trip: int) -> Dictionary:
	log_event("trip %d: heading out" % trip)
	await travel_to(&"forest")
	var gathered := await gather_until_full()
	log_event("trip %d: gathered %d (satchel %s)" % [trip, gathered, _satchel()])
	await travel_to(&"tavern")
	await store()
	var cooked := await cook_all()
	log_event("trip %d: cooked %d dishes" % [trip, cooked])
	var served := 0
	if not GameState.counter.is_empty():
		await set_open(true)
		served = await serve()
		await set_open(false)
	log_event("trip %d: served %d guests, coins %d" % [trip, served, GameState.coins])
	check("trip %d" % trip)
	return {"trip": trip, "gathered": gathered, "cooked": cooked, "served": served, "coins": GameState.coins}


# ------------------------------------------------------------------ actions
func travel_to(world_id: StringName) -> bool:
	if GameState.location == world_id:
		return true
	var in_tavern := GameState.location == &"tavern"
	var spot := main.current_world.get_spawn_position(&"entrance" if in_tavern else &"tavern_door")
	await go_to(spot)
	var direction := Vector2.DOWN if in_tavern else Vector2.UP
	var waited := 0.0
	while GameState.location != world_id or main.is_traveling():
		if main.player.input_enabled:
			_steer(direction)
		else:
			_release()
		await get_tree().physics_frame
		waited += get_physics_process_delta_time()
		if waited > 8.0:
			_release()
			problems.append("could not walk through the door to %s" % world_id)
			return false
	_release()
	await _physics(3)
	log_event("arrived: %s" % world_id)
	return true


func gather_until_full() -> int:
	var before: int = GameState.stats["items_gathered"]
	while GameState.satchel.free_space() > 0:
		var node := _nearest_available_node()
		if node == null:
			break
		var had := node.available()
		if not await use(node.get_node("Interactable"), "gather %s" % node.item.display_name) \
				or node.available() == had:
			_skipped_nodes[node.node_id] = true
	_skipped_nodes.clear()
	return GameState.stats["items_gathered"] - before


func store() -> void:
	if GameState.satchel.is_empty():
		return
	var pantry: Node = main.current_world.get_node("Actors/Pantry")
	await use(pantry.get_node("Interactable"), "store ingredients")
	if not GameState.satchel.is_empty():
		problems.append("satchel not empty after storing")


func cook_all() -> int:
	if _best_cookable() == null:
		return 0
	var hearth: Node = main.current_world.get_node("Actors/Hearth")
	if not await use(hearth.get_node("Interactable"), "open the hearth"):
		return 0
	var panel := main.cooking_panel
	var cooked := 0
	while panel.visible:
		var recipe := _best_cookable()
		if recipe == null:
			break
		var button := _recipe_button(recipe)
		if button == null or button.disabled:
			problems.append("cook button missing for %s" % recipe.id)
			break
		await _think()
		button.grab_focus()
		_press(&"interact")
		for stir in 3:  # optional stirring, like an eager cook
			await _seconds(0.2)
			_press(&"interact")
		var waited := 0.0
		while panel.is_cooking() and waited < 5.0:
			await _seconds(0.1)
			waited += 0.1
		cooked += 1
	_press(&"ui_cancel")
	await _physics(2)
	return cooked


func set_open(open: bool) -> bool:
	if GameState.tavern_open == open:
		return true
	var sign: Node = main.current_world.get_node("Actors/OpenSign")
	await use(sign.get_node("Interactable"), "open the tavern" if open else "close the tavern")
	if GameState.tavern_open != open:
		problems.append("sign did not %s the tavern" % ("open" if open else "close"))
		return false
	log_event("tavern %s" % ("opened" if open else "closed"))
	return true


func serve(max_idle_seconds: float = 30.0) -> int:
	var service: TavernService = main.current_world.get_node("Service")
	var served := 0
	var idle := 0.0
	while true:
		var guest := _serveable_guest(service)
		if guest != null:
			idle = 0.0
			var dish := guest.order.output.display_name
			if await use(guest.get_node("Interactable"), "serve %s" % dish) and not guest.is_waiting():
				served += 1
				log_event("served %s to a %s" % [dish, guest.data.display_name])
			continue
		if GameState.counter.is_empty() and service.guests().is_empty():
			break
		await _seconds(0.5)
		idle += 0.5
		if idle > max_idle_seconds:
			break
	return served


func buy_upgrade() -> bool:
	await use(main.current_world.get_node("UpgradeBoard"), "browse upgrades")
	await _think()
	_press(&"interact")  # the Buy button has focus when affordable
	await _physics(2)
	_press(&"ui_cancel")
	await _physics(2)
	if not GameState.owns_upgrade(SATCHEL_UPGRADE):
		problems.append("could not buy the satchel upgrade")
		return false
	log_event("bought Expanded Satchel (capacity %d)" % GameState.satchel.capacity)
	return true


## Pause -> Save -> Quit to Title -> Continue, then compares the restored session.
func save_quit_and_continue() -> bool:
	var before := {
		"coins": GameState.coins, "satchel": GameState.satchel.items(), "pantry": GameState.pantry.items(),
		"counter": GameState.counter.items(), "upgrades": GameState.owned_upgrades.keys(),
		"location": GameState.location, "capacity": GameState.satchel.capacity,
	}
	_press(&"pause")
	await _physics(2)
	await _choose_button(main.pause_menu, "Save Game")
	await _choose_button(main.pause_menu, "Quit to Title")
	if not main.title_screen.visible:
		problems.append("quit to title did not show the title")
		return false
	GameState.new_game()  # as if the game had been closed
	await _think()
	_press(&"interact")  # Continue has focus when a save exists
	await _physics(4)
	var after := {
		"coins": GameState.coins, "satchel": GameState.satchel.items(), "pantry": GameState.pantry.items(),
		"counter": GameState.counter.items(), "upgrades": GameState.owned_upgrades.keys(),
		"location": GameState.location, "capacity": GameState.satchel.capacity,
	}
	if after != before:
		problems.append("reload mismatch: %s vs %s" % [before, after])
		return false
	log_event("saved, quit to title and continued: progress intact")
	return true


# ------------------------------------------------------------------ interaction helpers
## Walks next to `target`, faces it, checks it is the HUD's target and presses interact.
func use(target: Interactable, label: String) -> bool:
	_ensure_nav()
	var options := []
	for offset: Vector2 in STAND_OFFSETS:
		var spot: Vector2 = target.global_position + offset
		if not _is_open(spot):
			continue
		var cost := spot.distance_to(main.player.global_position)
		if walk:
			var path := _path_to(spot)
			if path.is_empty():
				continue
			cost = path.size()
		options.append([cost, spot])
	options.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	for option: Array in options:
		if not await go_to(option[1]):
			continue
		await _face(target.global_position - main.player.global_position)
		await _think()
		if main.player.target == target:
			_press(&"interact")
			await _physics(2)
			return true
	problems.append("could not reach/use: %s in %s" % [label, GameState.location])
	return false


func go_to(point: Vector2, timeout: float = 40.0) -> bool:
	_ensure_nav()
	if not walk:
		main.player.global_position = point
		await _physics(2)
		return true
	for attempt in 3:
		var path := _path_to(point)
		if path.is_empty():
			break
		if await _follow(path, timeout):
			return true
	problems.append("stuck walking to %s in %s" % [point, GameState.location])
	return false


func log_event(text: String) -> void:
	var entry := {"t": snappedf(GameState.play_time, 0.1), "event": text, "coins": GameState.coins,
			"satchel": _satchel(), "where": String(GameState.location)}
	timeline.append(entry)
	print("[%6.1fs] %-7s coins=%-4d satchel=%-6s %s" % [entry.t, entry.where, entry.coins, entry.satchel, text])
	timeline_entry_logged.emit(entry)


## Conservation checks: nothing is created or destroyed outside the rules.
func ledger_violations() -> PackedStringArray:
	var out: PackedStringArray = []
	var s := GameState.stats
	var held := 0
	for inventory: Inventory in [GameState.satchel, GameState.pantry]:
		var contents := inventory.items()
		for id: StringName in contents:
			if contents[id] <= 0:
				out.append("non-positive count %s=%d" % [id, contents[id]])
			if GameDB.item(id).kind == ItemData.Kind.INGREDIENT:
				held += contents[id]
	if held != s["items_gathered"] - s["ingredients_used"]:
		out.append("ingredients held %d != gathered %d - used %d" % [held, s["items_gathered"], s["ingredients_used"]])
	if GameState.counter.total() != s["dishes_cooked"] - s["dishes_served"]:
		out.append("dishes on counter %d != cooked %d - served %d" % [GameState.counter.total(),
				s["dishes_cooked"], s["dishes_served"]])
	if GameState.coins != s["coins_earned"] - s["coins_spent"] or GameState.coins < 0:
		out.append("coins %d != earned %d - spent %d" % [GameState.coins, s["coins_earned"], s["coins_spent"]])
	if GameState.satchel.total() > GameState.satchel.capacity:
		out.append("satchel over capacity")
	return out


func check(step: String) -> void:
	for violation in ledger_violations():
		problems.append("%s: %s" % [step, violation])


# ------------------------------------------------------------------ navigation
func _ensure_nav() -> void:
	if is_instance_valid(_nav_world) and _nav_world == main.current_world:
		return
	_nav_world = main.current_world
	_nav = AStarGrid2D.new()
	_nav.region = Rect2i(Vector2i.ZERO, _nav_world.get_bounds().size / NAV_CELL)
	_nav.cell_size = Vector2(NAV_CELL, NAV_CELL)
	_nav.offset = Vector2.ONE * NAV_CELL / 2.0
	_nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_nav.update()
	var query := PhysicsShapeQueryParameters2D.new()
	var feet := RectangleShape2D.new()
	feet.size = Vector2(16, 10)  # the player's 14x8 feet box plus a margin
	query.shape = feet
	query.collision_mask = 1
	var space := _nav_world.get_world_2d().direct_space_state
	for y in _nav.region.size.y:
		for x in _nav.region.size.x:
			var cell := Vector2i(x, y)
			query.transform = Transform2D(0.0, _center(cell) + Vector2(0, -4))
			if not space.intersect_shape(query, 1).is_empty():
				_nav.set_point_solid(cell)


func _center(cell: Vector2i) -> Vector2:
	return Vector2(cell * NAV_CELL) + Vector2.ONE * NAV_CELL / 2.0


func _cell_of(point: Vector2) -> Vector2i:
	return Vector2i((point / NAV_CELL).floor()).clamp(Vector2i.ZERO, _nav.region.size - Vector2i.ONE)


func _is_open(point: Vector2) -> bool:
	return _nav.region.has_point(Vector2i((point / NAV_CELL).floor())) and not _nav.is_point_solid(_cell_of(point))


func _nearest_open_cell(point: Vector2) -> Variant:
	var origin := _cell_of(point)
	var best: Variant = null
	var best_distance := INF
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var cell := origin + Vector2i(dx, dy)
			if _nav.region.has_point(cell) and not _nav.is_point_solid(cell):
				var d := _center(cell).distance_to(point)
				if d < best_distance:
					best = cell
					best_distance = d
	return best


func _path_to(point: Vector2) -> PackedVector2Array:
	var from: Variant = _nearest_open_cell(main.player.global_position)
	var to: Variant = _nearest_open_cell(point)
	if from == null or to == null:
		return PackedVector2Array()
	var path := _nav.get_point_path(from, to)
	if not path.is_empty() and _is_open(point):
		path[path.size() - 1] = point
	return path


func _follow(path: PackedVector2Array, timeout: float) -> bool:
	var player := main.player
	var index := 0
	var elapsed := 0.0
	var anchor := player.global_position
	var since_anchor := 0.0
	while index < path.size():
		var to_point := path[index] - player.global_position
		var tolerance := 2.0 if index == path.size() - 1 else 6.0
		if to_point.length() <= tolerance:
			index += 1
			continue
		_steer(to_point)
		await get_tree().physics_frame
		var dt := get_physics_process_delta_time()
		elapsed += dt
		since_anchor += dt
		if since_anchor >= 0.6:
			if player.global_position.distance_to(anchor) < 3.0:
				_release()
				return false  # stuck: caller replans from here
			anchor = player.global_position
			since_anchor = 0.0
		if elapsed > timeout:
			_release()
			return false
	_release()
	await _physics(1)
	return true


# ------------------------------------------------------------------ input helpers
func _steer(direction: Vector2) -> void:
	var d := direction.normalized()
	_hold(&"move_right", maxf(0.0, d.x))
	_hold(&"move_left", maxf(0.0, -d.x))
	_hold(&"move_down", maxf(0.0, d.y))
	_hold(&"move_up", maxf(0.0, -d.y))


func _hold(action: StringName, strength: float) -> void:
	if strength > 0.01:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _release() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)


## A one-frame tap: turns the player to face `direction` (moving at most a pixel or two).
func _face(direction: Vector2) -> void:
	var axis := Vector2(signf(direction.x), 0) if absf(direction.x) > absf(direction.y) else Vector2(0, signf(direction.y))
	_steer(axis)
	await get_tree().physics_frame
	_release()
	await _physics(2)


func _press(action: StringName) -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()


func _choose_button(menu: Control, text: String) -> void:
	for button: Button in menu.find_children("*", "Button", true, false):
		if button.text == text:
			button.grab_focus()
			await _think()
			_press(&"interact")
			await _physics(3)
			return
	problems.append("menu button '%s' not found" % text)


func _think() -> void:
	if think_seconds > 0.0:
		await _seconds(think_seconds)


func _seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _physics(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame


# ------------------------------------------------------------------ queries
## Gathers like a player planning a dish: finish the recipe that is closest to complete (after
## counting what full portions are already in hand), picking the nearest node that helps.
func _nearest_available_node() -> GatherNode:
	var wanted := _wanted_ingredients()
	var best: GatherNode = null
	var best_score := INF
	for node in main.current_world.find_children("*", "", true, false):
		if node is GatherNode and node.available() > 0 and not _skipped_nodes.has(node.node_id):
			var score: float = node.global_position.distance_to(main.player.global_position)
			if not wanted.has(node.item.id):
				score *= 4.0  # still possible, but a detour for something no dish needs yet
			if score < best_score:
				best = node
				best_score = score
	return best


func _wanted_ingredients() -> Dictionary:
	var have := {}
	for inventory: Inventory in GameState.cooking_sources():
		var contents := inventory.items()
		for id: StringName in contents:
			have[id] = have.get(id, 0) + contents[id]
	var recipes := GameDB.recipes()
	recipes.sort_custom(func(a: RecipeData, b: RecipeData) -> bool: return a.output.price > b.output.price)
	var used_portion := true
	while used_portion:  # set aside every portion that can already be cooked
		used_portion = false
		for recipe in recipes:
			if recipe.ingredients.keys().all(func(id: StringName) -> bool: return have.get(id, 0) >= recipe.ingredients[id]):
				for id: StringName in recipe.ingredients:
					have[id] -= recipe.ingredients[id]
				used_portion = true
				break
	var best_missing := {}
	var best_total := 1 << 30
	for recipe in recipes:
		var missing := {}
		var total := 0
		for id: StringName in recipe.ingredients:
			var short: int = recipe.ingredients[id] - have.get(id, 0)
			if short > 0:
				missing[id] = short
				total += short
		if total < best_total:
			best_total = total
			best_missing = missing
	return best_missing


func _best_cookable() -> RecipeData:
	var best: RecipeData = null
	for recipe in GameDB.recipes():
		if Cooking.can_cook(recipe, GameState.cooking_sources()):
			if best == null or recipe.output.price > best.output.price:
				best = recipe
	return best


func _recipe_button(recipe: RecipeData) -> Button:
	for row in main.cooking_panel.find_child("RecipeList", true, false).get_children():
		for label: Label in row.find_children("*", "Label", true, false):
			if label.text.begins_with(recipe.output.display_name):
				var buttons := row.find_children("*", "Button", true, false)
				return buttons[0] if not buttons.is_empty() else null
	return null


func _serveable_guest(service: TavernService) -> Guest:
	for guest in service.guests():
		if guest.is_waiting() and GameState.counter.count(guest.order.output.id) > 0:
			return guest
	return null


func _satchel() -> String:
	return "%d/%d" % [GameState.satchel.total(), GameState.satchel.capacity]
