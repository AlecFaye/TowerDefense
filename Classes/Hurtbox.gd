class_name Hurtbox
extends Area2D

enum CollisionMask {
	NONE = 0
	PLAYER = 1,
	TOWER = 256,
}

export (Array, CollisionMask) var collision_masks = [CollisionMask.TOWER]


func _init() -> void:
	set_collision_layer(CollisionMask.NONE)
	
	for mask in collision_masks:
		set_collision_mask(mask)


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(var hitbox: Hitbox) -> void:
	if hitbox == null:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
		if hitbox.is_in_group("Projectile"):
			hitbox.remove_self()
