extends "res://Effects/Effect.gd"

onready var hitbox = $Sprite/Hitbox


func set_damage(var new_damage: int) -> void:
	hitbox.damage = new_damage


func set_damage_type(var new_damage_type: int = PrimaryDamageType.PHYSICAL) -> void:
	hitbox.damage_type = new_damage_type
