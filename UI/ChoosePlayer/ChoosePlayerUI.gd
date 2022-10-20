extends Control

export (PackedScene) var CatButton
export (PackedScene) var LevelSelector
export (PackedScene) var TutorialLevel

var cat_names = [
	"Cleopatra",
	"Jupiter",
	"Kurai",
	"Loki",
	"Luna"
]
var sprite_scale: Vector2 = Vector2(5, 5)
var selected_cat_name: String = "Cleopatra"

onready var cat_choice_container = $"%CatChoiceContainer"
onready var animated_icon_holder = $"%AnimatedIcon"


func _ready() -> void:
	_load_cat_buttons()


func _load_cat_buttons() -> void:
	for cat_name in cat_names:
		var cat_button = CatButton.instance()
		cat_button.set_name(cat_name)
		cat_button.connect("button_up", self, "_load_animated_icon", [cat_name])
		cat_choice_container.add_child(cat_button)


func _load_animated_icon(var cat_name: String = "Cleopatra") -> void:
	_clear_animated_icon()
	var icon = load("res://UI/ChoosePlayer/AnimatedIcons/%sIcon.tscn" % cat_name).instance()
	var icon_position = Vector2(animated_icon_holder.rect_size.x / 2, animated_icon_holder.rect_size.y / 2 + 128)
	
	icon.set_scale(sprite_scale)
	icon.set_position(icon_position)
	animated_icon_holder.add_child(icon)
	
	$"%CatName".text = cat_name
	selected_cat_name = cat_name
	
	_set_confirm_button_visibility(true)


func _clear_animated_icon() -> void:
	for node in animated_icon_holder.get_children():
		node.queue_free()


func _set_confirm_button_visibility(var is_visible: bool = true) -> void:
	$ConfirmButton.set_visible(is_visible)


func _on_ConfirmButton_button_up() -> void:
	WorldVariables.cat_name = selected_cat_name
	WorldVariables.is_cat_chosen = true
	
	if WorldVariables.is_tutorial_completed:
		if get_tree().change_scene_to(LevelSelector) != OK:
			print("Error loading scene")
			get_tree().quit()
	else:
		if get_tree().change_scene_to(TutorialLevel) != OK:
			print("Error loading scene")
			get_tree().quit()
