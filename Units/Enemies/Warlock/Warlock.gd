extends "res://Units/Enemies/Enemy.gd"

const SPELL_CAST_TIME: float = 0.8

export (int) var target_range = 5
export (int) var heal_amount = 12

var spell_cast_timer: Timer = null

onready var targeting_area = $TargetingArea


func _ready() -> void:
	_connect_timers()
	targeting_area.start(target_range)


func _connect_timers() -> void:
	attack_cooldown_timer.stop()
	attack_cooldown_timer.set_wait_time(attack_cooldown_time)
	attack_cooldown_timer.start()
	
	spell_cast_timer = Timer.new()
	spell_cast_timer.set_one_shot(true)
	spell_cast_timer.set_wait_time(SPELL_CAST_TIME)
	spell_cast_timer.connect("timeout", self, "_cast_heal_spell")
	$Timers.add_child(spell_cast_timer)


func _cast_heal_spell() -> void:
	for body in targeting_area.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			var enemy = body
			if enemy.has_method("heal") and enemy.unit_type != "Warlock":
				enemy.heal(heal_amount)


# Takes damage
func take_damage(var damage_taken: int = 10, var type = PrimaryDamageType.PHYSICAL) -> void:
	if is_dead: return
	
	if health_type == type:
		damage_taken = int(float(damage_taken) * primary_damage_reduction)
	
	health.set_current_hp(health.current_hp - damage_taken)
	
	if health.current_hp <= 0: return
	if is_attacking or is_casting: return
	
	animation_player.play("Hurt")
	is_hurt = true
	yield(animation_player, "animation_finished")
	is_hurt = false


func _on_AttackCooldownTimer_timeout():
	is_casting = true
	animation_player.play("Spellcast")
	spell_cast_timer.start()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Spellcast":
			is_casting = false
			attack_cooldown_timer.start()
