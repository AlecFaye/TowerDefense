extends Popup
  
export (Vector2) var icon_scale = Vector2(3, 3)
export (PackedScene) var AbilityContainer

var icon_position: Vector2 = Vector2(112, 164)

# Left Page 1
onready var animated_icon = $"%AnimatedIconControl"

# Right Page 1
onready var tower_name = $"%TowerName"
onready var range_amount_label = $"%RangeAmount"
onready var target_type_label = $"%TargetType"
onready var sell_amount_label = $"%SellAmount"
onready var upgrade_amount_label = $"%UpgradeAmount"
onready var upgrade_button = $"%UpgradeButton"

# Right Page 2
onready var abilities_container = $"%Abilities"

var tabs: Array = []
var book_tabs: Array = []

var current_tower = null


func _ready() -> void:
	tabs = $TabContainer.get_children()
	_connect_tabs()
	_add_book_tabs()
	_on_Tab_button_up(0)


func display_tower_info(var tower_info) -> void:
	current_tower = tower_info
	
	_update_tower_sprite()
	_update_tower_name()
	_update_tower_stats()
	_update_tower_costs()
	
	_clear_abilities_page()
	_fill_out_abilities_page()
	
	upgrade_button.set_disabled(current_tower.unit_level == current_tower.MAX_LEVEL)
	upgrade_amount_label.set_visible(current_tower.unit_level < current_tower.MAX_LEVEL)
	
	self.popup()


func _clear_abilities_page() -> void:
	for node in abilities_container.get_children():
		node.queue_free()


func _fill_out_abilities_page() -> void:
	for ability in current_tower.abilities:
		if current_tower.unit_level >= ability["LevelUnlocked"]:
			var ability_container = AbilityContainer.instance()
			abilities_container.add_child(ability_container)
			ability_container.load_ability(ability["Name"], ability["LevelUnlocked"])


func _connect_tabs() -> void:
	for index in range(tabs.size()):
		var tab = tabs[index]
		tab.connect("button_up", self, "_on_Tab_button_up", [index])


func _add_book_tabs() -> void:
	for index in range(1, tabs.size() + 1):
		book_tabs.append($MarginContainer/Pages.get_child(index))


func _get_roman_numeral(var digit: int) -> String:
	match digit:
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		5:
			return "V"
		6:
			return "VI"
		7:
			return "VII"
		_:
			return ""


func _get_target_string(var target_type: int) -> String:
	match target_type:
		current_tower.Targeting.FIRST:
			return "FIRST"
		current_tower.Targeting.LAST:
			return "LAST"
		current_tower.Targeting.CLOSE:
			return "CLOSE"
		_:
			return ""


func _update_tower_name() -> void:
	for tower in WorldVariables.tower_info:
		if tower["FilePath"] == current_tower.unit_type:
			tower_name.text = tower["Name"] + " " + _get_roman_numeral(current_tower.unit_level)


func _update_tower_stats() -> void:
	range_amount_label.text = str(current_tower.target_range)
	target_type_label.text = _get_target_string(current_tower.target_type)


func _update_tower_costs() -> void:
	sell_amount_label.text = str(current_tower.sell_amount)
	upgrade_amount_label.text = str(current_tower.upgrade_amount)


func _update_tower_sprite() -> void:
	animated_icon.get_child(0).queue_free()
	var icon = load("res://UI/AnimatedIcons/%sIcon.tscn" % current_tower.unit_type).instance()
	icon.set_scale(icon_scale)
	icon.position = icon_position
	animated_icon.add_child(icon)


func _on_SellButton_button_up():
	var current_level = get_tree().get_current_scene()
	current_level.deposit_gold(current_tower.sell_amount)
	
	get_tree().get_current_scene().remove_tower(current_tower.cell_position)
	current_tower.queue_free()
	self.set_visible(false)


func _on_UpgradeButton_button_up():
	var current_level = get_tree().get_current_scene()
	
	if not current_level.withdraw_gold(current_tower.upgrade_amount):
		return
	
	current_tower.increase_level()
	_clear_abilities_page()
	_fill_out_abilities_page()
	
	_update_tower_name()
	_update_tower_stats()
	_update_tower_costs()
	
	$UpgradeParticles.set_emitting(true)
	
	if current_tower.unit_level == current_tower.MAX_LEVEL:
		upgrade_button.set_disabled(true)
		upgrade_amount_label.set_visible(false)


func _on_CloseButton_button_up():
	current_tower.display_target_range(false)
	$UpgradeParticles.set_emitting(false)
	self.set_visible(false)


func _on_TowerInfoPopup_about_to_show() -> void:
	_on_Tab_button_up(0)


func _on_TowerInfoPopup_popup_hide() -> void:
	_on_CloseButton_button_up()


func _on_Tab_button_up(var tab_number: int):
	for index in range(tabs.size()):
		var tab = tabs[index]
		var book_tab = book_tabs[index]
		
		tab.tab(index == tab_number)
		book_tab.set_visible(index == tab_number)
