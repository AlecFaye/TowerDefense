extends HBoxContainer

onready var ability_name = $AbilityName
onready var level = $Level


func load_ability(var _ability_name: String, var _level: int) -> void:
	ability_name.text = _ability_name
	level.text = str(_level)
