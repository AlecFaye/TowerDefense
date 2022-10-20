extends Node2D

const LEVEL_SCENE_INDEX: int = 1

var title_screen_path = "res://UI/TitleScreen/TitleScreen.tscn"
var level_selector_path = "res://UI/LevelSelector/LevelSelector.tscn"

var game_levels = []
var tower_info = []

var level_path = "Level_01"
var level_name = "Level 1"
var level_index = 0

var cat_name: String = "Cleopatra"
var is_cat_chosen: bool = false

var is_tutorial_completed = true


func _ready() -> void:
	_load_level_info()
	_load_tower_info()


func load_level(var level_number: int = 0) -> void:
	if level_number >= game_levels.size():
		print("Finished Game")
		get_tree().quit()
		return
	
	var level = game_levels[level_number]
	level_path = level["FilePath"]
	level_index = level_number
	level_name = level["Name"]
	
	var level_scene = "res://Levels/%s/%s.tscn" % [level_path, level_path]
	
	if get_tree().change_scene(level_scene) != OK:
		print("Error loading scene %s" % level_scene)
		get_tree().quit()


func return_to_main_menu() -> void:
	if get_tree().change_scene(title_screen_path) != OK:
		print("Error loading title screen")
		get_tree().quit()


func save_level_info() -> void:
	var file = File.new()
	file.open("res://Data/Levels/LevelInfo.json", file.WRITE)
	
	var level_info_dict = {}
	for level in game_levels:
		level_info_dict[level["Name"]] = level
	
	file.store_line(to_json(level_info_dict))
	file.close()


func _load_level_info() -> void:
	var file = File.new()
	var file_path = "res://Data/Levels/LevelInfo.json"
	
	if not file.file_exists(file_path):
		file_path = "res://Data/Levels/DefaultLevelInfo.json"
	
	file.open(file_path, file.READ)
	
	var text = file.get_as_text()
	var level_info_dict = {}
	level_info_dict = parse_json(text)
	file.close()
	
	for level in level_info_dict.values():
		game_levels.append(level)
	game_levels.sort()


func _load_tower_info() -> void:
	var file = File.new()
	file.open("res://Data/Towers/TowerInfo.json", file.READ)
	
	var text = file.get_as_text()
	var tower_info_dict = {}
	tower_info_dict = parse_json(text)
	file.close()
	
	for tower in tower_info_dict.values():
		tower_info.append(tower)


func reset_level_info() -> void:
	var file = File.new()
	var file_path = "res://Data/Levels/DefaultLevelInfo.json"
	
	file.open(file_path, file.READ)
	
	var text = file.get_as_text()
	var level_info_dict = {}
	level_info_dict = parse_json(text)
	file.close()
	
	for level in level_info_dict.values():
		game_levels.append(level)
	game_levels.sort()


func reset_tower_info() -> void:
	var file = File.new()
	var file_path = "res://Data/Towers/DefaultTowerInfo.json"
	
	file.open(file_path, file.READ)
	
	var text = file.get_as_text()
	var tower_info_dict = {}
	tower_info_dict = parse_json(text)
	file.close()
	
	for tower in tower_info_dict.values():
		tower_info.append(tower)
