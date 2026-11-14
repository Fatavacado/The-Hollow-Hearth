extends TestCase
## Runtime session state (the GameState autoload).


func after_each() -> void:
	GameState.new_game()


func test_new_game_resets_location_and_play_time() -> void:
	GameState.location = &"forest"
	GameState.play_time = 99.0
	GameState.new_game()
	assert_eq(GameState.location, &"tavern")
	assert_eq(GameState.play_time, 0.0)


func test_play_time_accumulates_while_session_active() -> void:
	GameState.new_game()
	GameState.advance_time(1.5)
	GameState.advance_time(0.25)
	assert_almost_eq(GameState.play_time, 1.75, 0.0001)


func test_play_time_frozen_when_no_session() -> void:
	GameState.new_game()
	GameState.advance_time(1.0)
	GameState.end_session()
	GameState.advance_time(5.0)
	assert_almost_eq(GameState.play_time, 1.0, 0.0001)
