extends KinematicBody2D

signal died

enum PrimaryDamageType {
	PHYSICAL = 1,
	MAGICAL = 2,
	TRUE = 3
}

enum SecondaryDamageType {
	NORMAL,
	FIRE,
	ICE,
	POISON,
	HOLY
}

# Exported Variables
export (String) var unit_type = ""
export (float) var speed = 100.0
export (int) var gravity = 50
export (int) var basic_attack_damage =  10
export (float) var attack_cooldown_time = 1.0
export (bool) var facing_right = true

# Flippable Nodes
var flip: Node2D = null
var sprite: Sprite = null

# Timer Nodes
var remove_body_timer: Timer = null
var attack_cooldown_timer: Timer = null

# Other Nodes
var health: Node = null
var animation_player: AnimationPlayer = null
var position_target: Position2D = null

# State Variables
var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false

# Other Variables
var on_attack_cooldown: bool = false
var velocity: Vector2 = Vector2.ZERO
var target = null


func _enter_tree() -> void:
	animation_player = $AnimationPlayer
	remove_body_timer = $Timers/RemoveBodyTimer
	attack_cooldown_timer = $Timers/AttackCooldownTimer
	health = $Health
	flip = $Flip
	sprite = $Flip/Sprite


func _ready() -> void:
	if not facing_right:
		flip.scale.x = -flip.scale.x


# Kills the unit
func die() -> void:
	if is_dead: return
	
	is_dead = true
	
	emit_signal("died")
	
	animation_player.play("Death")
	yield(animation_player, "animation_finished")
	
	remove_body_timer.start()
	yield(remove_body_timer, "timeout")
	self.queue_free()


# Takes damage
func take_damage(var damage_taken: int = 10) -> void:
	if is_dead: return
	
	health.set_current_hp(health.current_hp - damage_taken)
	
	if health.current_hp <= 0: return
	if is_attacking: return
	
	animation_player.play("Hurt")
	is_hurt = true
	yield(animation_player, "animation_finished")
	is_hurt = false


# Get the facing direction
func _get_facing_direction() -> int:
	if facing_right: return 1
	return -1


# Flips the unit
func _flip_unit() -> void:
	if facing_right:
		facing_right = false
	else:
		facing_right = true
	flip.scale.x = -flip.scale.x


# Puts attack on a cooldown
func _start_attack_cooldown(var time: float = attack_cooldown_time) -> void:
	on_attack_cooldown = true
	yield(get_tree().create_timer(time, false), "timeout")
	
	if is_instance_valid(self):
		on_attack_cooldown = false
