extends Control

export (PackedScene) var UnitSelectorButton

var unit_selector_container: HBoxContainer = null


func _enter_tree() -> void:
	unit_selector_container = $InnerMargin/UnitSelectorContainer


func add_unit(var unit: Dictionary) -> void:
	var unit_selector_button = UnitSelectorButton.instance()
	unit_selector_button.set_unit_name(unit["Name"])
	unit_selector_button.set_unit_cost(unit["BaseCost"])
	unit_selector_button.set_unit_icon(unit["FilePath"], unit["Unlocked"])
	unit_selector_button.set_disabled(not unit["Unlocked"])
	unit_selector_button.connect("button_up", self, "_select_unit", [unit])
	unit_selector_container.add_child(unit_selector_button)
	unit_selector_button.set_unit_number(unit_selector_container.get_children().size())


func select_unit(var index: int = 0) -> void:
	unit_selector_container.get_child(index).emit_signal("button_up")


func _select_unit(var unit: Dictionary) -> void:
	if not unit["Unlocked"]: return
	get_parent().get_parent().set_selected_unit(unit)
