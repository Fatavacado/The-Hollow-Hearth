extends Prop
## Tavern pantry chest: stores everything in the satchel. Cooking draws from the pantry first.

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	super()
	_interactable.prompt = "Store ingredients"
	_interactable.interacted.connect(_on_interacted)


func _on_interacted(_player: Player) -> void:
	var moved := InventoryTransactions.transfer_all(GameState.satchel, GameState.pantry)
	if moved > 0:
		Feedback.toast("Stored %d ingredient%s in the pantry." % [moved, "" if moved == 1 else "s"])
	else:
		Feedback.toast("Your satchel is empty.")
