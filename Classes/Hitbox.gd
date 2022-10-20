class_name Hitbox
extends Area2D

enum CollisionLayer {
	NONE = 0
	PLAYER = 1,
	TOWER = 256,
}

enum PrimaryDamageType {
	PHYSICAL = 1,
	MAGICAL = 2,
	TRUE = 3
}

export (CollisionLayer) var coll_layer = CollisionLayer.TOWER
export (int) var damage = 10
export (PrimaryDamageType) var damage_type = PrimaryDamageType.PHYSICAL


func _init() -> void:
	set_collision_layer(coll_layer)
	set_collision_mask(CollisionLayer.NONE)


func remove_self() -> void:
	if owner.has_method("remove_self"):
		owner.remove_self()
