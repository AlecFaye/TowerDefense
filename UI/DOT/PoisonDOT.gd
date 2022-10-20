extends "res://UI/DOT/BaseDOT.gd"

export (PackedScene) var Poison


func _physics_process(_delta) -> void:
	if is_inflicted and can_take_DOT_damage:
		_display_effects()
		_take_DOT_damage()


func _display_effects() -> void:
	var poison = Poison.instance()
	get_parent().add_child(poison)
