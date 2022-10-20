extends "res://Effects/Effect.gd"

var damage = 5 setget set_damage
var damage_type: int = PrimaryDamageType.PHYSICAL setget set_damage_type

onready var hitbox = $Sprite/Hitbox


func set_damage_type(var new_damage_type: int = PrimaryDamageType.PHYSICAL) -> void:
	hitbox.damage_type = new_damage_type


func set_damage(var new_damage: int) -> void:
	hitbox.damage = new_damage
