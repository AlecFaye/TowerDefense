extends Popup


func _on_NextLevel_button_up():
	if get_tree().change_scene(WorldVariables.level_selector_path) != OK:
		print("Error loading scene")
		get_tree().quit()


func _on_MainMenu_button_up():
	if get_tree().change_scene(WorldVariables.title_screen_path) != OK:
		print("Error loading scene")
		get_tree().quit()
