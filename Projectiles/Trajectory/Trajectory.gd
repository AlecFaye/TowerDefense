extends Area2D

export (float) var max_speed = 250.0
export (PackedScene) var AfterEffect

var trajectory_animation = preload("res://Projectiles/Trajectory/Animations/Trajectory.tres")
var speed: float = 250
var max_height: float = -150.0
var max_time: float = 2.0

var damage
var damage_type

onready var sprite = $Sprite
onready var tween = $Tween
onready var animation_player = $AnimationPlayer


func _physics_process(delta) -> void:
	movement(delta)


func start(var pos: Vector2, var target) -> void:
	self.position = pos
	sprite.rotation = Vector2(1, 0).angle_to((target.global_position - pos).normalized())
	var rot_offset = abs(Vector2(1, 0).dot((target.global_position - pos).normalized()))
	speed = (max_speed / 2) + ((max_speed / 2) * rot_offset)
	
	var time = (pos.distance_to(target.global_position)) / max_speed
	tween.interpolate_property(
			self, "position",
			pos, target.global_position,
			time,
			Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	tween.start()
	
	var new_anim = trajectory_animation.duplicate()
	animation_player.remove_animation("Trajectory")
	animation_player.add_animation("Trajectory", new_anim)
	
	var position_track = animation_player.get_animation("Trajectory").find_track("Sprite:position")
	animation_player.get_animation("Trajectory").track_set_key_value(position_track, 1, Vector2(0.0, time / max_time * max_height))
	animation_player.playback_speed = 1 / time
	animation_player.play("Trajectory")


func movement(var delta: float) -> void:
	var velocity = Vector2(speed * delta, 0)
	position += velocity.rotated($Sprite.rotation)


func set_damage(var new_damage) -> void:
	damage = new_damage


func set_damage_type(var new_damage_type) -> void:
	damage_type = new_damage_type


func _play_after_effect() -> void:
	if AfterEffect == null: 
		return
	
	var after_effect = AfterEffect.instance()
	after_effect.set_as_toplevel(true)
	after_effect.global_position = self.global_position
	get_parent().add_child(after_effect)
	after_effect.set_damage(damage)
	after_effect.set_damage_type(damage_type)


func _on_Timer_timeout():
	pass # Replace with function body.


func _on_Tween_tween_completed(_object, _key):
	_play_after_effect()
	self.queue_free()
