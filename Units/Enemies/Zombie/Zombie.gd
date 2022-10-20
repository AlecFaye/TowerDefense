extends "res://Units/Enemies/Enemy.gd"


func spawn() -> void:
	animation_player.play("Spawn")
	is_spawning = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Spawn":
			is_spawning = false
