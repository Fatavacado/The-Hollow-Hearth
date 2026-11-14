class_name ItemData
extends Resource
## Immutable definition of an item (ingredient or dish). Runtime counts live in `Inventory`.

enum Kind { INGREDIENT, DISH }

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var kind: Kind = Kind.INGREDIENT
@export var icon: Texture2D
## Coins a guest pays for a dish before any tip. Ingredients are not sold in the slice.
@export var price: int = 0
