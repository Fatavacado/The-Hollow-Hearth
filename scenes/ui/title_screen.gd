class_name TitleScreen
extends Control
## Title over the live tavern: New Game, Continue (only with a save) and Quit, plus the controls.

signal new_game_requested
signal continue_requested
signal quit_requested

@onready var _new_game: Button = %NewGameButton
@onready var _continue: Button = %ContinueButton
@onready var _quit: Button = %QuitButton


func _ready() -> void:
	_new_game.pressed.connect(choose.bind(&"new_game"))
	_continue.pressed.connect(choose.bind(&"continue"))
	_quit.pressed.connect(choose.bind(&"quit"))


func open() -> void:
	show()
	refresh()


func refresh() -> void:
	_continue.disabled = not SaveService.has_save()
	(_continue if not _continue.disabled else _new_game).grab_focus()


func can_continue() -> bool:
	return not _continue.disabled


func choose(option: StringName) -> void:
	match option:
		&"new_game":
			new_game_requested.emit()
		&"continue":
			if can_continue():
				continue_requested.emit()
		&"quit":
			quit_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"interact"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused is Button and is_ancestor_of(focused) and not (focused as Button).disabled:
			(focused as Button).pressed.emit()
		get_viewport().set_input_as_handled()
