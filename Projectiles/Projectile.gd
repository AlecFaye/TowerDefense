extends Node2D

enum PrimaryDamageType {
	PHYSICAL = 1,
	MAGICAL = 2
}

export (float) var speed
export (String, "OneShot", "Persist") var projectile_type = "OneShot"

var velocity: Vector2 = Vector2.ZERO
var acceleration: Vector2 = Vector2.ZERO

var facing_right: bool = true

var target = null

onready var lifetime_timer = $LifetimeTimer
onready var hitbox = $Sprite/Hitbox


func _ready() -> void:
	if not facing_right:
		$Sprite.scale.x = -$Sprite.scale.x
	self.add_to_group(projectile_type)


func remove_self() -> void:
	match projectile_type:
		"OneShot":
			self.queue_free()


func set_damage_type(var new_damage_type: int = PrimaryDamageType.PHYSICAL) -> void:
	hitbox.damage_type = new_damage_type


func set_damage(var new_damage: int) -> void:
	hitbox.damage = new_damage


# Orients the projectile
func _orient_projectile() -> void:
	if target == null:
		return
	
	if self.global_position.x < target.global_position.x and not facing_right:
		_flip_projectile()
	elif self.global_position.x > target.global_position.x and facing_right:
		_flip_projectile()


# Flips the projectile
func _flip_projectile() -> void:
	if facing_right:
		facing_right = false
	else:
		facing_right = true
	self.scale.x = -self.scale.x


func _get_facing_direction() -> int:
	if facing_right:
		return 1
	return -1


func _on_LifetimeTimer_timeout():
	self.queue_free()
