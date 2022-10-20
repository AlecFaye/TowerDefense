extends "res://Units/Enemies/Empire/BaseSpawnUnit.gd"

onready var attack_range_hitbox = $Flip/AttackRange


func _physics_process(_delta) -> void:
	if is_moving_back_to_post:
		var distance = post.global_position.distance_to(self.global_position)
		is_moving_back_to_post = distance > EPSILON
	
	if is_attacking or is_hurt or is_dead or is_moving_back_to_post: return
	
	if _is_far_from_post():
		move_to_post()
		return
	
	if on_attack_cooldown:
		current_state = Animations.IDLE
	
	var is_chasing_enemy: bool = false
	if _is_enemy_in_range():
		if _is_enemy_in_attack_range() and not on_attack_cooldown:
			_attack()
		elif not _is_enemy_in_attack_range() or on_attack_cooldown:
			is_chasing_enemy = true
			current_state = Animations.MOVE
	else:
		current_state = Animations.IDLE
	
#	if target != null:
#		_orient_unit(target.global_position)
	_update_animations()
	
	if is_chasing_enemy:
		velocity = position.direction_to(target.global_position) * speed
		if position.distance_to(target.global_position) > EPSILON:
			velocity = move_and_slide(velocity)


# Uses a basic attack
func _attack() -> void:
	is_attacking = true
	animation_player.play("Attack")
	yield(animation_player, "animation_finished")
	_start_attack_cooldown()
	is_attacking = false


# Checks if the enemy is within attack range
func _is_enemy_in_attack_range() -> bool:
	for area in attack_range_hitbox.get_overlapping_areas():
		if area.is_in_group("EnemyHitbox"):
			return true
	return false


# Updates the animations at the end of the frame
func _update_animations() -> void:
	if is_attacking: return
	
	match current_state:
		Animations.IDLE:
			animation_player.play("Idle")
		Animations.MOVE:
			animation_player.play("Move")


func _on_HalberdAttack_area_entered(area):
	if area.is_in_group("EnemyHitbox"):
		var enemy = area.get_parent().get_parent()
		enemy.take_damage(basic_attack_damage)
