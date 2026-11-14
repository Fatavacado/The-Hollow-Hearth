class_name UpgradeData
extends Resource
## Immutable purchasable upgrade. The slice has one: the Expanded Satchel.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var cost := 60
## Extra satchel capacity granted once owned.
@export var satchel_bonus := 0
