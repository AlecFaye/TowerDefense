extends "res://Units/Enemies/Enemy.gd"

export (int) var target_range = 3
export (Vector2) var dark_grasp_offset = Vector2(8, -53)
export (PackedScene) var DarkGrasp
export (int) var shield_amount = 25


func _ready() -> void:
	$TargetingArea.start(target_range)


func _shield_allies() -> void:
	for area in $TargetingArea.get_overlapping_areas():
		if area.is_in_group("EnemyHitbox"):
			var enemy = area.get_parent().get_parent()
			if enemy.has_method("shield") and not enemy.is_shielded and enemy.can_be_shielded:
				enemy.shield(shield_amount)
				var dark_grasp = DarkGrasp.instance()
				dark_grasp.position = Vector2(dark_grasp.position.x + dark_grasp_offset.x, dark_grasp.position.y + dark_grasp_offset.y)
				enemy.add_child(dark_grasp)


func _on_TargetingArea_area_entered(area):
	if on_attack_cooldown: return
	
	if area.is_in_group("EnemyHitbox"):
		var enemy = area.get_parent().get_parent()
		if enemy.has_method("shield") and not enemy.is_shielded and enemy.can_be_shielded:
			is_casting = true
			animation_player.play("Cast")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Cast":
			is_casting = false
			_start_attack_cooldown()
			_shield_allies()
