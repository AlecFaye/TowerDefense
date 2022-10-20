extends Area2D

const DEFAULT_HITBOX = [
	Vector2(-64, 0),
	Vector2(0, -32),
	Vector2(64, 0),
	Vector2(0, 32)
]

onready var hitbox = $Hitbox
onready var visible_range = $VisibleRange


func start(var target_range: int = 1) -> void:
	_set_up_hitbox(target_range)


# Sets up the hitbox with their respective targeting range
func _set_up_hitbox(var target_range: int = 1) -> void:
	var new_polygon = []
	for point in DEFAULT_HITBOX:
		new_polygon.append(point * target_range)
	hitbox.set_polygon(new_polygon)
	visible_range.set_polygon(new_polygon)
