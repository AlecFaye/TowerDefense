extends "res://Units/Towers/Tower.gd"

const CAST_SPELL_TIME: float = 0.8

export (float) var speed_debuff = 0.3
export (int) var num_of_sunbolts = 8
export (PackedScene) var SlowAreaParticles
export (PackedScene) var SunBolt

var create_bolt_time: float = 0.25


func _physics_process(_delta) -> void:
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
			_slow_enemies()
		AbilityNumber.SECOND:
			_judgement()


func _slow_enemies() -> void:
	animation_player.play("Slow")
	yield(get_tree().create_timer(CAST_SPELL_TIME, false), "timeout")
	
	for body in targeting_area.get_overlapping_bodies():
		if not body.is_in_group("Enemy"):
			continue
		
		var enemy = body
		if enemy.is_slowed or enemy.is_dead:
			continue
		
		enemy.speed *= (1 - speed_debuff)
		enemy.is_slowed = true
		
		var slow_area_particles = SlowAreaParticles.instance()
		var hurtbox = enemy.get_node("%Hurtbox").get_node("CollisionShape2D")
		var shape = hurtbox.shape.extents
		var emission_shape = Vector3(shape.x, shape.y, 1)
		slow_area_particles.get_process_material().set_emission_box_extents(emission_shape)
		slow_area_particles.position = hurtbox.position
		enemy.add_child(slow_area_particles)


func _judgement() -> void:
	animation_player.play("Attack")
	yield(get_tree().create_timer(CAST_SPELL_TIME, false), "timeout")
	
	var screen_width = get_viewport_rect().size.x
	var width_offset = screen_width / (num_of_sunbolts + 1)
	var x_coordinate = 0
	var y_coordinate = 32
	
	for _count in range(1, num_of_sunbolts + 1):
		x_coordinate += width_offset
		var sunbolt_position = Vector2(x_coordinate, y_coordinate)
		_create_sunbolt(sunbolt_position)
		yield(get_tree().create_timer(create_bolt_time, false), "timeout")
	
	var screen_height = get_viewport_rect().size.y
	x_coordinate = 0
	y_coordinate = screen_height - 32
	
	for _count in range(1, num_of_sunbolts + 1):
		x_coordinate += width_offset
		var sunbolt_position = Vector2(x_coordinate, y_coordinate)
		_create_sunbolt(sunbolt_position)
		yield(get_tree().create_timer(create_bolt_time, false), "timeout")


func _create_sunbolt(var sunbolt_position: Vector2) -> void:
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	var sunbolt = SunBolt.instance()
	sunbolt.global_position = sunbolt_position
	sunbolt.set_as_toplevel(true)
	self.add_child(sunbolt)
	sunbolt.set_damage(damage)
	sunbolt.set_damage_type(damage_type)


func _on_TargetingArea_body_exited(body: Node) -> void:
	if body.is_in_group("Enemy"):
		var enemy = body
		if enemy.is_slowed:
			enemy.speed /= (1 - speed_debuff)
			enemy.is_slowed = false
			
			var slow_particles = enemy.get_node("SlowAreaParticles")
			if slow_particles:
				slow_particles.queue_free()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Slow", "Attack":
			is_attacking = false
