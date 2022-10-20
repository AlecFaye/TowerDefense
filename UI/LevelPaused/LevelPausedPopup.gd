extends Popup

signal unpause


func _on_Resume_button_up() -> void:
	get_tree().paused = false
	self.set_visible(false)


func _on_LevelSelector_button_up() -> void:
	if get_tree().change_scene(WorldVariables.level_selector_path) != OK:
		print("Error loading scene")
		get_tree().quit()
	get_tree().paused = false


func _on_MainMenu_button_up():
	if get_tree().change_scene(WorldVariables.title_screen_path) != OK:
		print("Error loading scene")
		get_tree().quit()
	get_tree().paused = false


func _on_LevelPausedPopup_about_to_show() -> void:
	get_tree().paused = true


func _on_LevelPausedPopup_popup_hide() -> void:
	emit_signal("unpause")
	get_tree().paused = false
	self.set_visible(false)
