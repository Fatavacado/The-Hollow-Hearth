extends TestCase
## Audio autoload: named sound effects and one looping ambience per world.


func after_each() -> void:
	Audio.set_ambience(&"")


func test_every_registered_sound_can_play() -> void:
	assert_true(Audio.sound_names().size() >= 8)
	for sound in Audio.sound_names():
		assert_true(Audio.play(sound), "sound %s" % sound)


func test_unknown_sounds_are_refused_quietly() -> void:
	assert_false(Audio.play(&"no_such_sound"))


func test_each_world_has_a_looping_ambience() -> void:
	for world_id: StringName in [&"tavern", &"forest"]:
		assert_true(Audio.set_ambience(world_id), "ambience for %s" % world_id)
		assert_true(Audio.ambience_playing())
		assert_eq(Audio.ambience_stream().loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s loops" % world_id)


func test_a_world_without_ambience_is_silent() -> void:
	Audio.set_ambience(&"forest")
	assert_false(Audio.set_ambience(&"nowhere"))
	assert_false(Audio.ambience_playing())
