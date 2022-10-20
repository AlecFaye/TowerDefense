extends "res://Projectiles/Projectile.gd"


func _physics_process(delta) -> void:
	if (not is_instance_valid(target) or target.is_dead):
		lifetime_timer.start()
	
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	self.rotation = velocity.angle()
	self.position += velocity * delta


func start(_position, _target = null) -> void:
	self.global_position = _position
	var vector = (_target.position_target.global_position - _position).normalized()
	velocity = vector * speed
	target = _target
