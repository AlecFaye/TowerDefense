extends Popup


func _on_Retry_button_up():
	if get_tree().reload_current_scene() != OK:
		print("Error loading scene")
		get_tree().quit()


func _on_MainMenu_button_up():
	if get_tree().change_scene(WorldVariables.title_screen_path) != OK:
		print("Error loading scene")
		get_tree().quit()


func _on_LevelSelector_button_up() -> void:
	if get_tree().change_scene(WorldVariables.level_selector_path) != OK:
		print("Error loading scene")
		get_tree().quit()


func _on_LevelFailedPopup_popup_hide() -> void:
	self.set_visible(false)
