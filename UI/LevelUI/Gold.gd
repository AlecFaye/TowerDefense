extends Node

const MAX_GOLD: int = 999999

signal gold_changed(new_amount)

onready var current_gold setget set_current_gold


func _ready() -> void:
	emit_signal("gold_changed", current_gold)


# Sets the current coins
func set_current_gold(var new_value: int) -> void:
	current_gold = new_value
	current_gold = clamp(current_gold, 0, MAX_GOLD)
	emit_signal("gold_changed", current_gold)
