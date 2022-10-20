extends "res://Units/Towers/Tower.gd"

const THROW_FLASK_TIME: float = 0.9

export (PackedScene) var BlueFlask
export (PackedScene) var GreenFlask
export (PackedScene) var RedFlask


func _enter_tree() -> void:
	targeting_area = $TargetingArea


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
	
	match ability_number:
		AbilityNumber.FIRST:
			animation_player.play("BlueAttack")
		AbilityNumber.SECOND:
			animation_player.play("GreenAttack")
		AbilityNumber.THIRD:
			animation_player.play("RedAttack")
	yield(get_tree().create_timer(THROW_FLASK_TIME, false), "timeout")
	
	_cast_ability(ability_number)
	yield(animation_player, "animation_finished")
	
	_start_ability_cooldown(ability_number)
	is_attacking = false


func _cast_ability(var ability_number: int) -> void:
	match ability_number:
		AbilityNumber.FIRST:
			_throw_blue_flask()
		AbilityNumber.SECOND:
			_throw_green_flask()
		AbilityNumber.THIRD:
			_throw_red_flask()


func _select_ability() -> int:
	for index in range(abilities.size() - 1, -1, -1):
		var ability = abilities[index]
		if ability["AbilityUnlocked"] and not ability["OnCooldown"]:
			return index
	return -1


func _throw_blue_flask() -> void:
	var damage = abilities[AbilityNumber.FIRST]["AbilityStats"][unit_level - 1]["Damage"]
	var flask = BlueFlask.instance()
	flask.set_as_toplevel(true)
	self.add_child(flask)
	flask.start(self.global_position, target)
	flask.set_damage(damage)
	flask.set_damage_type(damage_type)


func _throw_green_flask() -> void:
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	var flask = GreenFlask.instance()
	flask.set_as_toplevel(true)
	self.add_child(flask)
	flask.start(self.global_position, target)
	flask.set_damage(damage)
	flask.set_damage_type(damage_type)


func _throw_red_flask() -> void:
	var damage = abilities[AbilityNumber.THIRD]["AbilityStats"][unit_level - 1]["Damage"]
	var flask = RedFlask.instance()
	flask.set_as_toplevel(true)
	self.add_child(flask)
	flask.start(self.global_position, target)
	flask.set_damage(damage)
	flask.set_damage_type(damage_type)
