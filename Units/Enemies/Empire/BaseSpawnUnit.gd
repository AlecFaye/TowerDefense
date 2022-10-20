extends "res://Units/Unit.gd"

const EPSILON: int = 1

enum Animations {
	IDLE,
	MOVE
}

export (int) var targeting_range = 2

var chase_distance: int = 64

var is_moving_back_to_post: bool = false
var current_state: int = Animations.IDLE

onready var targeting_area = $TargetingArea
onready var movement_tween = $MovementTween
onready var post = $Post


func _ready() -> void:
	targeting_area.start(targeting_range)
	post.set_as_toplevel(true)


# Moves back to the post
func move_to_post() -> void:
	target = post
#	if target != null:
#		_orient_unit(target.global_position)
	is_moving_back_to_post = true
	animation_player.play("Move")
	movement_tween.interpolate_property(
			self, "global_position", self.global_position, post.global_position,
			1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	movement_tween.start()


# Checks if the unit is far from the post
func _is_far_from_post() -> bool:
	var current_to_post_distance = post.global_position.distance_to(self.global_position)
	return current_to_post_distance > chase_distance * targeting_range


# Checks if the enemy is in range
func _is_enemy_in_range() -> bool:
	target = null
	for body in targeting_area.get_overlapping_bodies():
		if not body.is_in_group("Enemy"): 
			continue
		if body.is_dead: 
			continue
		
		if target != null:
			if body.positioning_node.get_unit_offset() > target.positioning_node.get_unit_offset():
				target = body
		else:
			target = body
	
	return target != null
