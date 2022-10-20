extends "res://Units/Towers/Tower.gd"

const ASSASSINATE_CAST_TIME: float = 1.0
const SHURIKEN_CAST_TIME: float = 0.4

export (PackedScene) var Shuriken

var is_moving_back_to_post: bool = false
var chase_distance: int = 160
var chase_tween: SceneTreeTween = null
var shuriken_offset: Vector2 = Vector2(3, -10)

onready var attack_range_hitbox = $Flip/AttackRange/CollisionShape2D
onready var attack_hitbox = $Flip/AttackHitbox
onready var assasinate_hitbox = $Flip/AssassinateHitbox


func _physics_process(_delta) -> void:
	if is_attacking or is_hurt or is_dead or is_moving_back_to_post: return
	
	if _is_far_from_post():
		_move_to_post()
		return
	
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
			_twin_attack()
		AbilityNumber.SECOND:
			_assassinate()
		AbilityNumber.THIRD:
			_rampaging_shuriken()


func _twin_attack() -> void:
	chase_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	chase_tween.tween_property(self, "global_position", target.global_position, 0.8)
	animation_player.play("Run")
	attack_range_hitbox.set_disabled(false)
	
	var damage = abilities[AbilityNumber.FIRST]["AbilityStats"][unit_level - 1]["Damage"]
	attack_hitbox.set_damage(damage)
	attack_hitbox.set_damage_type(damage_type)
	
	yield(chase_tween, "finished")
	if is_attacking and animation_player.get_current_animation() != "Attack":
		animation_player.play("Attack")


func _assassinate() -> void:
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	assasinate_hitbox.set_damage(damage)
	assasinate_hitbox.set_damage_type(damage_type)
	
	var destination_position = target.global_position
	animation_player.play("SpecialAttack")
	yield(get_tree().create_timer(ASSASSINATE_CAST_TIME, false), "timeout")
	self.global_position = destination_position


func _rampaging_shuriken() -> void:
	animation_player.play("Throw")
	yield(get_tree().create_timer(SHURIKEN_CAST_TIME, false), "timeout")
	_throw_shuriken()


func _throw_shuriken() -> void:
	var shuriken = Shuriken.instance()
	var shuriken_position = Vector2(self.global_position.x + shuriken_offset.x, self.global_position.y + shuriken_offset.y)
	shuriken.set_as_toplevel(true)
	shuriken.facing_right = self.facing_right
	self.add_child(shuriken)
	
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	shuriken.start(shuriken_position, target)
	shuriken.set_damage(damage)
	shuriken.set_damage_type(damage_type)


# Moves back to the post
func _move_to_post() -> void:
	_orient_unit(world_position)
	
	is_moving_back_to_post = true
	animation_player.play("Run")
	
	var move_tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "global_position", world_position, 1.0)
	
	yield(move_tween, "finished")
	is_moving_back_to_post = false


# Checks if the unit is far from the post
func _is_far_from_post() -> bool:
	var current_to_post_distance = world_position.distance_to(self.global_position)
	return current_to_post_distance > chase_distance


func _on_AttackRange_body_entered(body: KinematicBody2D) -> void:
	if body.is_in_group("Enemy"):
		if body.is_dead:
			return
		animation_player.play("Attack")
		chase_tween.stop()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Attack":
			is_attacking = false
			attack_range_hitbox.set_disabled(true)
		"SpecialAttack", "Throw":
			is_attacking = false
