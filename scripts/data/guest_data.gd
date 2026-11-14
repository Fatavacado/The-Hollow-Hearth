class_name GuestData
extends Resource
## Immutable guest archetype: look, tastes, pacing and a few personality lines.

@export var id: StringName = &""
@export var display_name: String = ""
@export var sprite_sheet: Texture2D
@export var sheet_columns := 5
@export var sheet_rows := 4
## Ghosts drift instead of walking (bob animation, no walk cycle).
@export var floats := false
@export var walk_speed := 70.0
## Dish item ids this guest prefers; they are ordered more often and earn `tip`.
@export var favorite_dishes: Array[StringName] = []
@export var tip := 4
@export var patience_seconds := 90.0
@export var eat_seconds := 2.5
@export var arrival_line := ""
@export var favorite_line := ""
@export var thanks_line := ""
@export var leave_line := ""
