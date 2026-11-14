extends Interactable
## The notice board on the tavern wall: browse and buy upgrades.


func _ready() -> void:
	super()
	prompt = "Browse upgrades"
	interacted.connect(func(_player: Player) -> void: Feedback.open_panel(&"upgrades"))
