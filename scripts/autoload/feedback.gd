extends Node
## Player-facing feedback channel (autoload "Feedback"): gameplay code reports what happened or
## asks for a panel; Main/HUD decide how to show it. Keeps rules and world objects free of UI refs.

signal toast_requested(text: String, icon: Texture2D)
signal panel_requested(panel_id: StringName)
## True while a dish is cooking (drives hearth steam and similar ambience).
signal cooking_changed(active: bool)


func toast(text: String, icon: Texture2D = null) -> void:
	toast_requested.emit(text, icon)


func open_panel(panel_id: StringName) -> void:
	panel_requested.emit(panel_id)


func set_cooking(active: bool) -> void:
	cooking_changed.emit(active)
