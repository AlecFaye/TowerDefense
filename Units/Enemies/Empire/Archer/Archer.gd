extends "res://Units/Towers/Paladin/Empire/BaseSpawnUnit.gd"

const SHOOT_ARROW_TIME: float = 1.0

export (PackedScene) var Arrow
export (Vector2) var arrow_offset = Vector2.ZERO


func _physics_process(_delta) -> void:
	if is_moving_back_to_post:
		var distance = post.global_position.distance_to(self.global_position)
		is_moving_back_to_post = distance > EPSILON
	
	if is_attacking or is_hurt or is_dead or is_moving_back_to_post: return
	
	current_state = Animations.IDLE
	
	if on_attack_cooldown:
		current_state = Animations.IDLE
	
	if _is_enemy_in_range() and not on_attack_cooldown:
		_attack()
	
	if target != null:
		_orient_unit(target.global_position)
	_update_animations()


func _attack() -> void:
	is_attacking = true
	animation_player.play("Attack")
	yield(get_tree().create_timer(SHOOT_ARROW_TIME, false), "timeout")
	_shoot_arrow()
	yield(animation_player, "animation_finished")
	_start_attack_cooldown()
	is_attacking = false


func _shoot_arrow() -> void:
	var arrow = Arrow.instance()
	var arrow_position = Vector2(self.global_position.x + arrow_offset.x, self.global_position.y + arrow_offset.y)
	
	if not facing_right:
		arrow.scale.x = -arrow.scale.x
	arrow.facing_right = facing_right
	arrow.start(arrow_position, target)
	arrow.set_as_toplevel(true)
	self.add_child(arrow)


# Updates the animations at the end of the frame
func _update_animations() -> void:
	if is_attacking: return
	
	match current_state:
		Animations.IDLE:
			animation_player.play("Idle")
		Animations.MOVE:
			animation_player.play("Move")
