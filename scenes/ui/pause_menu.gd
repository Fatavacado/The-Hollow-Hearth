class_name PauseMenu
extends Control
## Pause menu (keeps running while the tree is paused): Resume, Save Game, Quit to Title.

signal resume_requested
signal save_requested
signal quit_to_title_requested

@onready var _resume: Button = %ResumeButton
@onready var _save: Button = %SaveButton
@onready var _quit: Button = %QuitToTitleButton


func _ready() -> void:
	hide()
	_resume.pressed.connect(choose.bind(&"resume"))
	_save.pressed.connect(choose.bind(&"save"))
	_quit.pressed.connect(choose.bind(&"quit_to_title"))


func open() -> void:
	show()
	_resume.grab_focus()


func close() -> void:
	hide()


func choose(option: StringName) -> void:
	match option:
		&"resume":
			resume_requested.emit()
		&"save":
			save_requested.emit()
		&"quit_to_title":
			quit_to_title_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		choose(&"resume")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"interact"):
		var focused := get_viewport().gui_get_focus_owner()
		if focused is Button and is_ancestor_of(focused):
			(focused as Button).pressed.emit()
		get_viewport().set_input_as_handled()
