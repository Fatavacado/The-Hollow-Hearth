extends TestCase
## Gather-node rules: yield into a limited satchel, deplete, regrow after play time passes.

const MAX := 3
const REGROW := 100.0


func test_untouched_node_offers_its_full_yield() -> void:
	assert_eq(Gathering.remaining({}, MAX, REGROW, 0.0), MAX)


func test_harvest_moves_the_yield_into_the_satchel() -> void:
	var satchel := Inventory.new(10)
	var result := Gathering.harvest({}, MAX, REGROW, 5.0, satchel, &"glowcap")
	assert_eq(result.gathered, 3)
	assert_eq(satchel.count(&"glowcap"), 3)
	assert_eq(result.state, {"remaining": 0, "depleted_at": 5.0})


func test_full_satchel_leaves_the_rest_on_the_node() -> void:
	var satchel := Inventory.new(2)
	var result := Gathering.harvest({}, MAX, REGROW, 5.0, satchel, &"glowcap")
	assert_eq(result.gathered, 2)
	assert_eq(result.state.remaining, 1)
	assert_eq(Gathering.remaining(result.state, MAX, REGROW, 500.0), 1, "partial nodes do not regrow")


func test_depleted_node_offers_nothing_until_regrown() -> void:
	var state := {"remaining": 0, "depleted_at": 10.0}
	assert_eq(Gathering.remaining(state, MAX, REGROW, 109.0), 0)
	assert_eq(Gathering.remaining(state, MAX, REGROW, 110.0), MAX)


func test_harvesting_a_depleted_node_gathers_nothing() -> void:
	var satchel := Inventory.new(10)
	var state := {"remaining": 0, "depleted_at": 10.0}
	var result := Gathering.harvest(state, MAX, REGROW, 20.0, satchel, &"glowcap")
	assert_eq(result.gathered, 0)
	assert_true(satchel.is_empty())
	assert_eq(result.state, state)


func test_harvesting_after_regrowth_restarts_the_cycle() -> void:
	var satchel := Inventory.new(10)
	var state := {"remaining": 0, "depleted_at": 10.0}
	var result := Gathering.harvest(state, MAX, REGROW, 200.0, satchel, &"glowcap")
	assert_eq(result.gathered, MAX)
	assert_eq(result.state, {"remaining": 0, "depleted_at": 200.0})
