extends Node2D
## World-space text that rises and fades, then frees itself (e.g. "+14" coins above a guest).

const RISE := 18.0
const SECONDS := 1.2

var text := ""
var color := Color(1.0, 0.84, 0.4)


func _ready() -> void:
	z_index = 20
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(-20, -6)
	label.size = Vector2(40, 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - RISE, SECONDS)
	tween.tween_property(self, "modulate:a", 0.0, SECONDS).set_delay(SECONDS * 0.5)
	tween.chain().tween_callback(queue_free)
