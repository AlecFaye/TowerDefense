extends "res://Levels/BaseLevel.gd"

signal started_wave
signal ended_wave

export (PackedScene) var LevelSelector


func _ready() -> void:
	_load_wave_info()


func _physics_process(_delta) -> void:
	if completed_level: return
	
	if is_spawning_enemies and enemies_killed >= total_enemies:
		if current_wave < waves.size():
			pause_towers()
			start_wave_button.set_visible(true)
			emit_signal("ended_wave")
			is_spawning_enemies = false
		else:
			_complete_tutorial_level()


func _complete_tutorial_level() -> void:
	WorldVariables.is_tutorial_completed = true
	completed_level = true
	$"%LevelCompletedPopup".popup()


func _load_wave_info() -> void:
	var file = File.new()
	file.open("res://Data/Levels/TutorialLevelInfo.json", file.READ)
	
	var text = file.get_as_text()
	var level_info_dict = {}
	level_info_dict = parse_json(text)
	file.close()
	
	for level_info in level_info_dict.values():
		if level_info["FilePath"] == self.name:
			waves = level_info["Waves"]


func _on_StartWaveButton_button_up():
	current_wave += 1
	
	if current_wave > waves.size(): 
		return
	
	emit_signal("started_wave")
	
	unpause_towers()
	start_wave_button.set_visible(false)
	level_info_UI.update_waves(current_wave, waves.size())
	_spawn_enemies()
