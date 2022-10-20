extends "res://Effects/Effect.gd"

export (float) var speed = 100.0
var positioning_node

onready var hitbox = $Sprite/Hitbox


func _physics_process(delta) -> void:
	if get_parent().is_class("PathFollow2D"):
		get_parent().offset += speed * delta
	
	if positioning_node:
		positioning_node.offset += speed * delta
		if positioning_node.loop == false and positioning_node.get_unit_offset() == 1.0:
			self.queue_free()


func set_damage_type(var new_damage_type: int = PrimaryDamageType.PHYSICAL) -> void:
	hitbox.damage_type = new_damage_type


func set_damage(var new_damage: int) -> void:
	hitbox.damage = new_damage
