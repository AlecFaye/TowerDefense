extends Control

enum TutorialState {
	SELECT_UNIT,
	PLACE_UNIT,
	START_WAVE,
	COLLECT_COINS,
	VIEW_TOWER_INFO,
	PLACE_ANOTHER_UNIT,
	START_WAVE_AGAIN
}

var current_state: int = TutorialState.SELECT_UNIT
var current_level = null

var tutorial_instructions = {
	TutorialState.SELECT_UNIT: "SELECTING A UNIT\n\nLeft-Click Unit\nOR\nPress 1",
	TutorialState.PLACE_UNIT: "PLACE UNIT\nLeft-Click\n\nOR\n\nDESELECT UNIT\nRight-Click",
	TutorialState.START_WAVE: "BEGIN WAVE\n\nPress Start to Begin",
	TutorialState.COLLECT_COINS: "COLLECT COINS\n\nRight-Click to Move",
	TutorialState.VIEW_TOWER_INFO: "VIEW TOWER INFO\n\nLeft-Click Unit on Map",
	TutorialState.PLACE_ANOTHER_UNIT: "PLACE ANOTHER UNIT\n\nLeft-Click Unit\nOR\nPress 1",
	TutorialState.START_WAVE_AGAIN: "SURVIVE\n\nPress Start to Begin"
}

var delay_time: float = 0.1


func _ready() -> void:
	current_level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)
	_load_instructions()


func _physics_process(_delta: float) -> void:
	_check_state()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("unit_1") and current_state == TutorialState.SELECT_UNIT:
		_load_next_tutorial()
	
	elif event.is_action_pressed("deselect"):
		if current_level.selected_unit and current_state == TutorialState.PLACE_UNIT:
			_load_previous_tutorial()
		elif current_state == TutorialState.COLLECT_COINS:
			_load_next_tutorial()
	
	elif event.is_action_pressed("select"):
		if not current_level.selected_unit and current_state == TutorialState.SELECT_UNIT:
			yield(get_tree().create_timer(delay_time, false), "timeout")
			if current_level.selected_unit:
				_load_next_tutorial()
		elif current_level.selected_unit and current_state == TutorialState.PLACE_UNIT:
			_load_next_tutorial()
			$"%StartWaveButton".set_disabled(false)
		elif current_level.selected_unit and current_state == TutorialState.PLACE_ANOTHER_UNIT:
			_load_next_tutorial()


func _check_state() -> void:
	match current_state:
		TutorialState.VIEW_TOWER_INFO:
			if current_level.selected_unit_on_map:
				_load_next_tutorial()


func _load_next_tutorial() -> void:
	current_state = int(clamp(current_state + 1, 0, tutorial_instructions.size() - 1))
	_load_instructions()


func _load_previous_tutorial() -> void:
	current_state = int(clamp(current_state - 1, 0, tutorial_instructions.size() - 1))
	_load_instructions()


func _load_instructions() -> void:
	$"%Instructions".text = tutorial_instructions[current_state]


func _on_TutorialLevel_started_wave() -> void:
	self.set_visible(false)


func _on_TutorialLevel_ended_wave() -> void:
	if current_state == TutorialState.START_WAVE:
		self.set_visible(true)
		_load_next_tutorial()


func _on_Retry_button_up() -> void:
	get_tree().reload_current_scene()
