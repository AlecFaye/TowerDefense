extends "res://Projectiles/Projectile.gd"

export (float) var steer_force = 35.0

var destination_position: Vector2 = Vector2.ZERO

var is_homing: bool = true


func _physics_process(delta):
	if (not is_instance_valid(target) or target.is_dead) and is_homing:
		lifetime_timer.start()
		is_homing = false
	
	if is_homing:
		acceleration += _seek()
	
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	self.rotation = velocity.angle()
	self.position += velocity * delta


func start(_position, _target = null) -> void:
	self.global_position = _position
	rotation += rand_range(-0.09, 0.09)
	velocity = transform.x * speed
	target = _target


func _seek() -> Vector2:
	var steer = Vector2.ZERO
	
	if target and is_instance_valid(target):
		var desired = (target.position_target.global_position - self.global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
		destination_position = target.position_target.global_position
	return steer
