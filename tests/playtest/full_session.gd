extends Node
## Timed playthrough of the whole slice with real movement (PlaytestAgent, walk = true).
## Starts from the title screen, plays until the satchel upgrade is bought plus one more trip,
## then saves, quits to title and continues. Writes a timeline report.
##
##   godot --path . res://tests/playtest/full_session.tscn -- --out=<dir> [--speed=4] [--shots]
##
## --speed scales game time (physics ticks scale with it, so the simulation is unchanged).
## --shots captures screenshots at milestones (needs a window, not --headless).

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const SHOT_KEYWORDS := ["gathered", "cooked", "opened", "served", "bought", "continued"]

var _out := ""
var _shots := false
var _shot_count := 0


func _ready() -> void:
	_out = _arg("--out=", OS.get_user_data_dir().path_join("playtest"))
	DirAccess.make_dir_recursive_absolute(_out)
	var speed := float(_arg("--speed=", "1"))
	_shots = "--shots" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless"
	Engine.time_scale = speed
	Engine.physics_ticks_per_second = int(60 * speed)
	Engine.max_physics_steps_per_frame = maxi(8, int(8 * speed))
	SaveService.save_path = "user://playtest_save.json"
	SaveService.delete_save()

	var main: Main = MAIN_SCENE.instantiate()
	add_child(main)
	await _frames(5)
	var agent := PlaytestAgent.new()
	agent.main = main
	agent.walk = true
	add_child(agent)
	await get_tree().create_timer(1.0).timeout
	agent._press(&"interact")  # "New Game" has focus on a fresh title screen
	await _frames(5)
	if main.title_screen.visible:
		push_error("New Game did not start from the title screen")
		get_tree().quit(1)
		return
	if _shots:
		agent.timeline_entry_logged.connect(_maybe_shoot)
	var report := await agent.run_session(1)
	_write_report(report)
	SaveService.delete_save()
	get_tree().quit(0 if report.ok else 1)


func _maybe_shoot(entry: Dictionary) -> void:
	for keyword: String in SHOT_KEYWORDS:
		if String(entry.event).contains(keyword):
			await RenderingServer.frame_post_draw
			_shot_count += 1
			var file := "%02d_%s.png" % [_shot_count, String(entry.event).left(28).validate_filename().replace(" ", "_")]
			get_viewport().get_texture().get_image().save_png(_out.path_join(file))
			return


func _write_report(report: Dictionary) -> void:
	var lines: PackedStringArray = []
	lines.append("# Playtest agent session")
	lines.append("")
	lines.append("| Measure | Value |")
	lines.append("|---|---|")
	lines.append("| Result | %s |" % ("PASS" if report.ok else "FAIL"))
	lines.append("| Game time played | %s |" % _clock(report.play_seconds))
	lines.append("| Upgrade bought at | %s |" % (_clock(report.upgrade_bought_at) if report.upgrade_bought_at >= 0.0 else "never"))
	lines.append("| Trips | %d |" % report.trips.size())
	lines.append("| Items gathered | %d |" % report.stats["items_gathered"])
	lines.append("| Dishes cooked / served | %d / %d |" % [report.stats["dishes_cooked"], report.stats["dishes_served"]])
	lines.append("| Coins earned / spent / held | %d / %d / %d |" % [report.stats["coins_earned"], report.stats["coins_spent"], report.coins])
	lines.append("| Gathered on the trip after the upgrade | %d |" % report.gathered_after_upgrade)
	lines.append("| Save -> title -> continue | %s |" % ("intact" if report.reload_ok else "FAILED"))
	lines.append("")
	lines.append("## Trips")
	lines.append("| Trip | Gathered | Cooked | Served | Coins after |")
	lines.append("|---|---|---|---|---|")
	for trip: Dictionary in report.trips:
		lines.append("| %d | %d | %d | %d | %d |" % [trip.trip, trip.gathered, trip.cooked, trip.served, trip.coins])
	lines.append("")
	lines.append("## Problems")
	if report.problems.is_empty():
		lines.append("None.")
	for problem: String in report.problems:
		lines.append("- " + problem)
	lines.append("")
	lines.append("## Timeline (game time)")
	for entry: Dictionary in report.timeline:
		lines.append("- `%s` %s — coins %d, satchel %s" % [_clock(entry.t), entry.event, entry.coins, entry.satchel])
	var file := FileAccess.open(_out.path_join("session_report.md"), FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("\n".join(lines.slice(0, 13)))
	print("report: ", _out.path_join("session_report.md"))


func _clock(seconds: float) -> String:
	return "%d:%02d" % [int(seconds) / 60, int(seconds) % 60]


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func _arg(prefix: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(prefix):
			return arg.trim_prefix(prefix)
	return fallback
