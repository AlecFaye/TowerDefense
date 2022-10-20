extends Control

export (PackedScene) var LevelSelectorButton


func _ready() -> void:
	load_level_buttons()


func load_level_buttons() -> void:
	var game_levels = WorldVariables.game_levels
	
	for level_index in game_levels.size():
		var level_info = game_levels[level_index]
		var level_button = LevelSelectorButton.instance()
		var level_position = $Positions.get_child(level_index)
		
		level_position.add_child(level_button)
		level_button.rect_position = Vector2(-level_button.rect_size.x / 2, -level_button.rect_size.y / 2)
		level_button.set_text(level_info["Name"])
		level_button.connect("button_up", self, "_load_level", [level_index])
		level_button.set_disabled(not level_info["LevelUnlocked"])


func _load_level(var level_number: int) -> void:
	WorldVariables.load_level(level_number)
