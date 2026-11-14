class_name TavernService
extends Node
## Runs guest arrivals while the tavern is open. A guest arrives only when a seat is free and there
## is something the keeper can actually serve (see Orders). Guests are never saved.

const GUEST_SCENE := preload("res://scenes/guests/guest.tscn")

@export var first_arrival_delay := 3.0
## Seconds between arrivals (random in [x, y]).
@export var arrival_interval := Vector2(9.0, 14.0)
## Where guests appear and where they leave (just inside the door).
@export var entry_point := Vector2(320, 330)
@export var actors_path: NodePath = ^"../Actors"
@export var seats_path: NodePath = ^"../Seats"

var rng := RandomNumberGenerator.new()
var _until_arrival := 0.0
var _guests: Array[Guest] = []
var _last_archetype: StringName = &""


func _ready() -> void:
	rng.randomize()
	GameState.tavern_open_changed.connect(_on_open_changed)


func guests() -> Array[Guest]:
	return _guests.filter(func(g: Guest) -> bool: return is_instance_valid(g))


## Dishes a new guest could be promised right now.
func orderable() -> Array[RecipeData]:
	var pending: Array[StringName] = []
	for guest in guests():
		if guest.state == Guest.State.ARRIVING or guest.state == Guest.State.WAITING:
			pending.append(guest.order.output.id)
	return Orders.orderable(GameDB.recipes(), GameState.counter, GameState.cooking_sources(), pending)


func _process(delta: float) -> void:
	if not GameState.tavern_open:
		return
	_until_arrival -= delta
	if _until_arrival > 0.0:
		return
	var seat := _free_seat()
	var options := orderable()
	if seat == null or options.is_empty():
		_until_arrival = 1.0  # check again shortly
		return
	_until_arrival = rng.randf_range(arrival_interval.x, arrival_interval.y)
	var data := Orders.choose_archetype(GameDB.guests(), _last_archetype, rng)
	_last_archetype = data.id
	var guest: Guest = GUEST_SCENE.instantiate()
	guest.setup(data, Orders.pick(data, options, rng), seat, entry_point)
	guest.finished.connect(_on_guest_finished)
	get_node(actors_path).add_child(guest)
	_guests.append(guest)


func _free_seat() -> Seat:
	var free: Array[Seat] = []
	for child in get_node(seats_path).get_children():
		if child is Seat and child.is_free():
			free.append(child)
	return free[rng.randi() % free.size()] if not free.is_empty() else null


func _on_guest_finished(guest: Guest) -> void:
	_guests.erase(guest)


func _on_open_changed(is_open: bool) -> void:
	if not is_open:
		Feedback.toast("Closed for now. No new guests will arrive.")
		return
	_until_arrival = first_arrival_delay
	if orderable().is_empty():
		Feedback.toast("Open! But there's nothing to serve yet. Cook a dish so guests have something to order.")
	else:
		Feedback.toast("The Hollow Hearth is open. Guests will drop by.")
