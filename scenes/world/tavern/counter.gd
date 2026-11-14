extends Prop
## Serving counter: shows the cooked dishes waiting to be served (up to one per slot).

## Icon top-left positions on the counter top, relative to the counter's base.
const SLOTS := [Vector2(-68, -45), Vector2(-48, -45), Vector2(-28, -45), Vector2(-8, -45),
		Vector2(12, -45), Vector2(32, -45), Vector2(52, -45)]

var _dish_sprites: Array[Sprite2D] = []


func _ready() -> void:
	super()
	GameState.counter.changed.connect(_refresh_dishes)
	_refresh_dishes()


func shown_dish_count() -> int:
	return _dish_sprites.size()


func _refresh_dishes() -> void:
	for sprite_node in _dish_sprites:
		sprite_node.queue_free()
	_dish_sprites.clear()
	var contents := GameState.counter.items()
	var ids := contents.keys()
	ids.sort()
	for id: StringName in ids:
		for i in contents[id]:
			if _dish_sprites.size() >= SLOTS.size():
				return
			var dish := Sprite2D.new()
			dish.texture = GameDB.item(id).icon
			dish.centered = false
			dish.position = SLOTS[_dish_sprites.size()]
			add_child(dish)
			_dish_sprites.append(dish)
