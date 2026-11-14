extends TestCase
## The complete vertical-slice loop, end to end, using only player-facing interactions:
## explore -> gather -> return -> store -> cook -> open -> serve -> earn -> upgrade -> explore again
## (carrying more) -> save -> quit to title -> continue. Conservation ledgers are checked after
## every trip. The agent teleports between targets and game time runs 6x for speed.

const SPEED := 6.0

var main: Main
var agent: PlaytestAgent


func before_each() -> void:
	SaveService.delete_save()
	Engine.time_scale = SPEED
	Engine.physics_ticks_per_second = int(60 * SPEED)
	main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	await wait_frames(3)
	main.start_new_game()
	agent = PlaytestAgent.new()
	agent.main = main
	agent.walk = false
	agent.think_seconds = 0.0
	add_child(agent)


func after_each() -> void:
	Engine.time_scale = 1.0
	Engine.physics_ticks_per_second = 60
	for action: StringName in PlaytestAgent.MOVE_ACTIONS:
		Input.action_release(action)
	agent.queue_free()
	main.queue_free()
	SaveService.delete_save()
	await wait_frames(2)


func test_complete_loop_with_upgrade_and_reload() -> void:
	var report := await agent.run_session(1)
	assert_true(report.problems.is_empty(), "problems:\n  " + "\n  ".join(report.problems))
	assert_true(GameState.owns_upgrade(&"expanded_satchel"), "the satchel upgrade was earned and bought")
	assert_true(report.gathered_after_upgrade > GameState.BASE_SATCHEL_CAPACITY,
			"the trip after the upgrade carried more (%d)" % report.gathered_after_upgrade)
	assert_true(report.reload_ok, "progress survived save -> title -> continue")
	assert_true(report.stats["dishes_served"] >= 4, "served %d" % report.stats["dishes_served"])
	assert_eq(agent.ledger_violations(), PackedStringArray())
