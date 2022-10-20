extends "res://Units/Towers/Tower.gd"

signal resize_finished
signal stomp_finished
signal walk_finished

export (int) var poison_DOT_damage
export (float) var stomp_air_offset = -100.0
export (float) var after_stomp_idle_time = 0.5
export (float) var resize_time = 0.5
export (Vector2) var grow_vector = Vector2(1.5, 1.5)
export (Vector2) var shrink_vector = Vector2(1, 1)
export (float) var feast_offset = -11.0

export (PackedScene) var StompParticles

var is_feasting = false

onready var feast_line = $FeastLine


func _enter_tree() -> void:
	targeting_area = $TargetingArea


func _exit_tree() -> void:
	if target != null and is_feasting:
		target.set_physics_process(true)


func _physics_process(_delta) -> void:
	_update_feast_line()
	if is_feasting: 
		return
	
	if is_attacking or is_hurt or is_dead: return
	
	var is_enemy_in_range = _is_enemy_in_range()
	var are_abilities_on_cd = _all_abilities_on_cooldown()
	
	if is_enemy_in_range:
		if not are_abilities_on_cd:
			_orient_unit(target.global_position)
			_attack()
		else:
			animation_player.play("Idle")
	else:
		animation_player.play("Idle")


func _attack() -> void:
	var ability_number = _select_ability()
	if ability_number == NO_ABILITY: 
		return
	
	is_attacking = true
	_cast_ability(ability_number)
	_start_ability_cooldown(ability_number)


func _cast_ability(var ability_number: int) -> void:
	match ability_number:
		AbilityNumber.FIRST:
			_poison_gas()
		AbilityNumber.SECOND:
			_grow_and_stomp()
		AbilityNumber.THIRD:
			_feast()


func _poison_gas() -> void:
	animation_player.play("PoisonGas")


func _grow_and_stomp() -> void:
	animation_player.play("ChargeUp")
	_resize(grow_vector)
	yield(self, "resize_finished")
	animation_player.play("Jump")
	_stomp()
	yield(self, "stomp_finished")
	animation_player.play("Idle")
	yield(get_tree().create_timer(after_stomp_idle_time, false), "timeout")
	_resize(shrink_vector)
	yield(self, "resize_finished")
	_walk(world_position)
	yield(self, "walk_finished")
	is_attacking = false


func _resize(var size: Vector2) -> void:
	var resize_tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	var set_size: Vector2 = Vector2(size.x * _get_facing_direction(), size.y)
	resize_tween.tween_property(flip, "scale", set_size, resize_time)
	yield(resize_tween, "finished")
	emit_signal("resize_finished")


func _stomp() -> void:
	var stomp_ground_position: Vector2 = target.global_position
	var stomp_air_position: Vector2 = Vector2(target.global_position.x, target.global_position.y + stomp_air_offset)
	
	var stomp_tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	stomp_tween.tween_property(self, "global_position", stomp_air_position, 0.5)
	stomp_tween.tween_property(self, "global_position", stomp_ground_position, 0.3)
	
	yield(stomp_tween, "finished")
	_display_stomp_particles(stomp_ground_position)
	emit_signal("stomp_finished")


func _walk(var destination_position: Vector2) -> void:
	var walk_tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	animation_player.play("Walk")
	_orient_walking(destination_position)
	walk_tween.tween_property(self, "global_position", destination_position, 1.5)
	walk_tween.play()
	yield(walk_tween, "finished")
	emit_signal("walk_finished")


func _feast() -> void:
	animation_player.play("Feast")
	feast_line.add_point(target.global_position)
	is_attacking = false
	is_feasting = true
	
	target.set_physics_process(false)
	var feast_tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	feast_tween.tween_property(target, "global_position", self.global_position, 2.5)
	
	yield(feast_tween, "finished")
	
	if target != null and not target.is_dead:
		if target.has_method("die"):
			target.die()
	
	is_feasting = false


func _update_feast_line() -> void:
	if feast_line.points.size() < 2:
		return
	
	feast_line.remove_point(1)
	
	if target == null or target.is_dead:
		is_feasting = false
		return
	
	var feast_final_position: Vector2 = Vector2(target.global_position.x - self.global_position.x, target.global_position.y - self.global_position.y + feast_offset)
	feast_line.add_point(feast_final_position)


func _display_stomp_particles(var particles_position: Vector2) -> void:
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	
	var stomp_particles = StompParticles.instance()
	stomp_particles.global_position = particles_position
	stomp_particles.set_as_toplevel(true)
	flip.add_child(stomp_particles)
	flip.scale = grow_vector
	
	stomp_particles.set_damage(damage)
	stomp_particles.set_damage_type(damage_type)


func _orient_walking(var destination_positon: Vector2) -> void:
	if self.global_position.x < destination_positon.x and not facing_right:
		_flip_unit()
	elif self.global_position.x > destination_positon.x and facing_right:
		_flip_unit()


func _on_PoisonHitbox_body_entered(body: KinematicBody2D) -> void:
	if body.is_in_group("Enemy"):
		if body.is_dead: return
		
		var poison_node = body.get_node("PoisonDOT")
		if poison_node:
			var damage = abilities[AbilityNumber.FIRST]["AbilityStats"][unit_level - 1]["Damage"]
			poison_node.set_damage(damage)
			poison_node.start_DOT()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"PoisonGas":
			is_attacking = false
