class_name RecipeData
extends Resource
## Immutable recipe: ingredients (item id -> amount) cooked at the hearth into one `output` dish.

@export var id: StringName = &""
@export var ingredients: Dictionary[StringName, int] = {}
@export var output: ItemData
## Base cook time; stirring (optional) shortens it.
@export var cook_seconds := 1.6
