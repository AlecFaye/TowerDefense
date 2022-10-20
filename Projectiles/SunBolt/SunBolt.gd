extends "res://Projectiles/Projectile.gd"

export (float) var steer_force = 35.0

var is_active: bool = false
var destination_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	rotation += rand_range(-0.5, 0.5)
	velocity = transform.x * speed


func _physics_process(delta: float) -> void:
	if not is_active: 
		return
	
	acceleration += _seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	self.rotation = velocity.angle()
	self.position += velocity * delta


func _seek() -> Vector2:
	var steer = Vector2.ZERO
	
	if target and is_instance_valid(target):
		var desired = (target.position_target.global_position - self.global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
		destination_position = target.position_target.global_position
	else:
		_get_next_enemy()
	
	return steer


func _get_next_enemy() -> void:
	var level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)
	var enemies = level.enemy_container
	
	for enemy in enemies.get_children():
		if not enemy.is_dead:
			target = enemy
			return


func _on_SetOffTimer_timeout() -> void:
	is_active = true
