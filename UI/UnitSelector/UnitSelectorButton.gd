extends TextureButton

var unit_name: String = ""
var unit_cost: int = 0


func set_unit_name(var u_name: String) -> void:
	unit_name = u_name


func set_unit_cost(var u_cost: int) -> void:
	unit_cost = u_cost
	$UnitCost.text = str(unit_cost)


func set_unit_number(var u_number: int) -> void:
	$UnitNumber.text = str(u_number)


func set_unit_icon(var u_path: String, var is_unlocked: bool) -> void:
	var icon = load("res://UI/AnimatedIcons/%sIcon.tscn" % u_path).instance()
	
	if not is_unlocked:
		icon.set_modulate(Color.black)
	
	set_button_text_visibility(is_unlocked)
	icon.position = Vector2(self.rect_size.x / 2, self.rect_size.y - 10)
	self.add_child(icon)


func set_button_text_visibility(var is_visible: bool = false) -> void:
	$UnitCost.set_visible(is_visible)
	$UnitNumber.set_visible(is_visible)
	$UnitCostBox.set_visible(is_visible)
	$UnitNumberBox.set_visible(is_visible)
