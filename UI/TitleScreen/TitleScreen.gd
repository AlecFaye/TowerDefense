extends Control

export (PackedScene) var LevelSelector
export (PackedScene) var TutorialLevel
export (PackedScene) var CharacterSelect


func _on_Play_button_up():
	if not WorldVariables.is_cat_chosen:
		if get_tree().change_scene_to(CharacterSelect) != OK:
			print("Error loading scene")
			get_tree().quit()
	elif WorldVariables.is_tutorial_completed:
		if get_tree().change_scene_to(LevelSelector) != OK:
			print("Error loading scene")
			get_tree().quit()
	else:
		if get_tree().change_scene_to(TutorialLevel) != OK:
			print("Error loading scene")
			get_tree().quit()


func _on_Quit_button_up():
	get_tree().quit()


func _on_ResetLevel_button_up():
	WorldVariables.reset_level_info()
