extends TextureButton

var cat_name: String = "" setget set_name


func set_name(var name: String) -> void:
	cat_name = name
	_update_label()


func _update_label() -> void:
	$Label.text = cat_name
