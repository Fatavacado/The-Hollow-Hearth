extends Node
## Mutable runtime state for the current play session (autoload "GameState").
## Definitions (items, recipes, guests) are immutable Resources in GameDB; anything that
## changes during play lives here so it can be reset, saved and loaded in one place.

## Emitted when something (a door, a menu) asks to move the player to another world.
signal travel_requested(world_id: StringName, spawn_id: StringName)
signal coins_changed(coins: int)
signal tavern_open_changed(is_open: bool)
signal upgrades_changed

const BASE_SATCHEL_CAPACITY := 10

var location: StringName = &"tavern"
var play_time: float = 0.0
var session_active: bool = false
## Carried ingredients (limited). The same object lives for the whole session; reset, never replace.
var satchel := Inventory.new(BASE_SATCHEL_CAPACITY)
## Tavern storage (unlimited).
var pantry := Inventory.new(Inventory.UNLIMITED)
## Cooked dishes waiting on the serving counter.
var counter := Inventory.new(Inventory.UNLIMITED)
## Gather-node runtime state by node id; see Gathering for the format.
var gather_nodes: Dictionary = {}
var coins := 0
## Upgrade id -> true for every upgrade bought.
var owned_upgrades: Dictionary = {}
## Guests only arrive while open. Never saved as open: a loaded game starts closed.
var tavern_open := false
## Session totals, used for feedback and economy consistency checks.
var stats := _fresh_stats()


func _process(delta: float) -> void:
	advance_time(delta)


func new_game() -> void:
	location = &"tavern"
	play_time = 0.0
	session_active = true
	satchel.load_counts({})
	satchel.set_capacity(BASE_SATCHEL_CAPACITY)
	pantry.load_counts({})
	counter.load_counts({})
	gather_nodes.clear()
	coins = 0
	owned_upgrades.clear()
	stats = _fresh_stats()
	set_tavern_open(false)
	coins_changed.emit(coins)
	upgrades_changed.emit()


func end_session() -> void:
	session_active = false


func advance_time(seconds: float) -> void:
	if session_active:
		play_time += seconds


func request_travel(world_id: StringName, spawn_id: StringName) -> void:
	travel_requested.emit(world_id, spawn_id)


## Harvests a gather node into the satchel. Returns how many items were gathered.
func gather(node_id: StringName, item_id: StringName, max_yield: int, regrow_seconds: float) -> int:
	var result := Gathering.harvest(gather_nodes.get(node_id, {}), max_yield, regrow_seconds,
			play_time, satchel, item_id)
	if result.gathered > 0:
		gather_nodes[node_id] = result.state
		stats["items_gathered"] += result.gathered
	return result.gathered


func node_remaining(node_id: StringName, max_yield: int, regrow_seconds: float) -> int:
	return Gathering.remaining(gather_nodes.get(node_id, {}), max_yield, regrow_seconds, play_time)


## Where cooking takes ingredients from, in order: the pantry first, then the satchel.
func cooking_sources() -> Array:
	return [pantry, satchel]


func cook(recipe: RecipeData) -> bool:
	if not Cooking.cook(recipe, cooking_sources(), counter):
		return false
	for id: StringName in recipe.ingredients:
		stats["ingredients_used"] += recipe.ingredients[id]
	stats["dishes_cooked"] += 1
	return true


func earn(amount: int) -> bool:
	if amount <= 0:
		return false
	coins += amount
	stats["coins_earned"] += amount
	coins_changed.emit(coins)
	return true


func spend(amount: int) -> bool:
	if amount <= 0 or amount > coins:
		return false
	coins -= amount
	stats["coins_spent"] += amount
	coins_changed.emit(coins)
	return true


func owns_upgrade(id: StringName) -> bool:
	return owned_upgrades.has(id)


## Charges the cost and applies the upgrade. Never charges twice or goes below zero.
func buy_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or owns_upgrade(upgrade.id) or not spend(upgrade.cost):
		return false
	owned_upgrades[upgrade.id] = true
	satchel.set_capacity(satchel_capacity())
	upgrades_changed.emit()
	return true


func satchel_capacity() -> int:
	var capacity := BASE_SATCHEL_CAPACITY
	for id: StringName in owned_upgrades:
		var upgrade := GameDB.upgrade(id)
		if upgrade != null:
			capacity += upgrade.satchel_bonus
	return capacity


func set_tavern_open(is_open: bool) -> void:
	if tavern_open == is_open:
		return
	tavern_open = is_open
	tavern_open_changed.emit(is_open)


func record_served() -> void:
	stats["dishes_served"] += 1


## Ledgers: coins == earned - spent; held ingredients == gathered - used; counter == cooked - served.
func _fresh_stats() -> Dictionary:
	return {"coins_earned": 0, "coins_spent": 0, "dishes_served": 0, "items_gathered": 0,
			"ingredients_used": 0, "dishes_cooked": 0}
