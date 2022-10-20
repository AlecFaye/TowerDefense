extends Node

signal max_hp_changed(new_max)
signal hp_changed(new_amount)

signal hp_depleted
export (int) var max_hp_amount = 100 setget set_max_hp

onready var current_hp = max_hp_amount setget set_current_hp


func _ready() -> void:
	emit_signal("max_hp_changed", max_hp_amount)
	emit_signal("hp_changed", current_hp)


# Sets the max hp
func set_max_hp(var new_max_hp: int) -> void:
	max_hp_amount = new_max_hp
	max_hp_amount = max(1, new_max_hp)
	emit_signal("max_hp_changed", max_hp_amount)


# Sets the current hp
func set_current_hp(var new_value: int) -> void:
	current_hp = new_value
	current_hp = clamp(current_hp, 0, max_hp_amount)
	emit_signal("hp_changed", current_hp)
	
	if current_hp == 0:
		emit_signal("hp_depleted")
