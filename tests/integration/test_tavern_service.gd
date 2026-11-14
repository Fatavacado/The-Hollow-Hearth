extends GameSession
## Opening the tavern, guest arrivals, orders, serving and payment in the real tavern scene.

var service: TavernService


func before_each() -> void:
	await super()
	service = main.current_world.get_node("Service")
	service.first_arrival_delay = 0.2
	service.arrival_interval = Vector2(0.4, 0.4)


func _sign() -> Node2D:
	return main.current_world.get_node("Actors/OpenSign")


func _wait_until(condition: Callable, timeout: float) -> bool:
	var waited := 0.0
	while waited < timeout:
		if condition.call():
			return true
		await wait_seconds(0.1)
		waited += 0.1
	return condition.call()


func _wait_for_seated_guest(timeout: float = 8.0) -> Guest:
	var seated := func() -> bool: return service.guests().any(func(g: Guest) -> bool: return g.is_waiting())
	if not await _wait_until(seated, timeout):
		return null
	for guest in service.guests():
		if guest.is_waiting():
			return guest
	return null


func test_the_sign_opens_and_closes_the_tavern() -> void:
	await stand_before(_sign())
	await press(&"interact")
	assert_true(GameState.tavern_open)
	assert_eq(main.hud.tavern_status_text(), "OPEN")
	await press(&"interact")
	assert_false(GameState.tavern_open)
	assert_eq(main.hud.tavern_status_text(), "CLOSED")


func test_no_guests_arrive_while_closed() -> void:
	GameState.counter.add(&"glowcap_soup", 2)
	await wait_seconds(1.0)
	assert_eq(service.guests().size(), 0)


func test_opening_with_nothing_to_serve_brings_no_guests_and_says_why() -> void:
	await stand_before(_sign())
	await press(&"interact")
	assert_true(last_toast().to_lower().contains("cook"), "hint: '%s'" % last_toast())
	await wait_seconds(1.0)
	assert_eq(service.guests().size(), 0)


func test_guests_arrive_and_order_what_is_available() -> void:
	GameState.counter.add(&"glowcap_soup", 1)
	GameState.set_tavern_open(true)
	var guest := await _wait_for_seated_guest()
	assert_not_null(guest, "a guest took a seat")
	if guest != null:
		assert_eq(guest.order.output.id, &"glowcap_soup")


func test_serving_the_ordered_dish_pays_and_the_guest_leaves() -> void:
	GameState.counter.add(&"glowcap_soup", 1)
	GameState.set_tavern_open(true)
	var guest := await _wait_for_seated_guest()
	assert_not_null(guest)
	if guest == null:
		return
	var expected := Orders.payment(guest.data, guest.order.output)
	GameState.set_tavern_open(false)  # no further arrivals during this check
	await stand_before(guest, 16.0)
	assert_true(main.hud.prompt_text().contains("Glowcap Soup"), "prompt '%s'" % main.hud.prompt_text())
	await press(&"interact")
	assert_eq(GameState.counter.count(&"glowcap_soup"), 0, "dish taken from the counter")
	assert_true(await _wait_until(func() -> bool: return GameState.coins == expected, guest.data.eat_seconds + 1.0),
			"paid %d" % expected)
	assert_eq(GameState.stats.dishes_served, 1)
	assert_true(await _wait_until(func() -> bool: return service.guests().is_empty(), 10.0), "guest left")


func test_serving_without_the_dish_changes_nothing() -> void:
	GameState.pantry.add(&"glowcap", 2)
	GameState.pantry.add(&"fernleaf", 1)
	GameState.set_tavern_open(true)
	var guest := await _wait_for_seated_guest()
	assert_not_null(guest)
	if guest == null:
		return
	GameState.set_tavern_open(false)
	await stand_before(guest, 16.0)
	await press(&"interact")
	assert_eq(GameState.coins, 0)
	assert_eq(GameState.pantry.count(&"glowcap"), 2, "serving never cooks implicitly")
	assert_true(guest.is_waiting(), "guest keeps waiting")
	assert_true(last_toast().to_lower().contains("cook"), "hint: '%s'" % last_toast())


func test_impatient_guest_leaves_without_paying() -> void:
	GameState.counter.add(&"glowcap_soup", 1)
	GameState.set_tavern_open(true)
	var guest := await _wait_for_seated_guest()
	assert_not_null(guest)
	if guest == null:
		return
	GameState.set_tavern_open(false)
	guest.patience_left = 0.05
	await wait_seconds(0.4)
	assert_false(guest.is_waiting())
	assert_eq(GameState.coins, 0)
	assert_eq(GameState.counter.count(&"glowcap_soup"), 1, "unserved dish stays on the counter")


func test_no_more_than_three_guests_at_once() -> void:
	GameState.counter.add(&"glowcap_soup", 10)
	GameState.set_tavern_open(true)
	await wait_seconds(3.0)
	assert_eq(service.guests().size(), 3)
	await wait_seconds(1.0)
	assert_eq(service.guests().size(), 3)


func test_closing_stops_arrivals_but_seated_guests_stay() -> void:
	GameState.counter.add(&"glowcap_soup", 5)
	GameState.set_tavern_open(true)
	var guest := await _wait_for_seated_guest()
	assert_not_null(guest)
	GameState.set_tavern_open(false)
	var count := service.guests().size()
	await wait_seconds(1.5)
	assert_eq(service.guests().size(), count, "no new arrivals after closing")
	assert_true(guest.is_waiting(), "seated guest can still be served")


func test_leaving_the_tavern_closes_it() -> void:
	GameState.counter.add(&"glowcap_soup", 1)
	GameState.set_tavern_open(true)
	await _wait_for_seated_guest()
	await travel(&"forest", &"tavern_door")
	assert_false(GameState.tavern_open)
	await travel(&"tavern", &"entrance")
	service = main.current_world.get_node("Service")
	assert_eq(service.guests().size(), 0)
	assert_eq(GameState.counter.count(&"glowcap_soup"), 1, "dish kept for next time")
