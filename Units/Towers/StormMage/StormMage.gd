extends "res://Units/Towers/Tower.gd"

const CAST_LIGHTNING_TIME: float = 0.9

export (PackedScene) var LightningBolt


func _enter_tree() -> void:
	targeting_area = $TargetingArea


func _physics_process(_delta) -> void:
	if is_attacking or is_hurt or is_dead: return
	
	if _is_enemy_in_range() and not on_attack_cooldown:
		_orient_unit(target.global_position)
		_attack()
	
	if on_attack_cooldown:
		animation_player.play("Idle")


func _attack() -> void:
	is_attacking = true
	animation_player.play("Attack")
	yield(get_tree().create_timer(CAST_LIGHTNING_TIME, false), "timeout")
	_cast_lightning_bolt()
	yield(animation_player, "animation_finished")
	_start_attack_cooldown()
	is_attacking = false


func _cast_lightning_bolt() -> void:
	var lightning_bolt = LightningBolt.instance()
	if not facing_right:
		lightning_bolt.scale.x = -lightning_bolt.scale.x
	lightning_bolt.facing_right = facing_right
	lightning_bolt.start(self.global_position, target)
	lightning_bolt.set_as_toplevel(true)
	self.add_child(lightning_bolt)
