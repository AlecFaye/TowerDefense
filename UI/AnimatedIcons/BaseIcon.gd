extends Node2D


onready var sprite = $Sprite
onready var visible_range = $Range


func initialize(var sprite_scale: Vector2, var range_multiplier) -> void:
	sprite.set_scale(sprite_scale)
	_set_up_range(range_multiplier)
	visible_range.set_visible(true)


# Sets up the hitbox with their respective targeting range
func _set_up_range(var range_multiplier) -> void:
	var new_polygon = []
	for point in visible_range.polygon:
		new_polygon.append(point * range_multiplier)
	visible_range.set_polygon(new_polygon)
