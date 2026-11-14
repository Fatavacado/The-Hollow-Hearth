extends Node
## Player-facing feedback channel (autoload "Feedback"): gameplay code reports what happened,
## the HUD decides how to show it. Keeps rules free of UI references.

signal toast_requested(text: String, icon: Texture2D)


func toast(text: String, icon: Texture2D = null) -> void:
	toast_requested.emit(text, icon)
