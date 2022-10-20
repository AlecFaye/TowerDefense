extends Node2D

enum PrimaryDamageType {
	PHYSICAL,
	MAGICAL
}

export (String) var animation_name
export (bool) var has_multiple_animations = false
export (float) var loop_time = 3.0
export (int) var times_repeated = 1

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if has_multiple_animations:
		_play_multiple_animations()
	else:
		_play_effect()


# Plays the effect if it only has one animation
func _play_effect() -> void:
	for _times_played in range(times_repeated):
		animation_player.play(animation_name)
		yield(animation_player, "animation_finished")
	self.queue_free()


# Plays the looping effect if it has multiple animations
func _play_multiple_animations() -> void:
	for _times_played in range(times_repeated):
		animation_player.play(animation_name + "Start")
		yield(animation_player, "animation_finished")
		
		animation_player.play(animation_name + "Loop")
		yield(get_tree().create_timer(loop_time, false), "timeout")
		
		animation_player.play(animation_name + "End")
		yield(animation_player, "animation_finished")
	self.queue_free()
