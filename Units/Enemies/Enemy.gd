extends "res://Units/Unit.gd"

signal deplete_level_health(amount)

enum HealthType {
	HEALTH = 0,
	ARMOUR = 1,
	MAGICAL = 2
}

export (HealthType) var health_type
export (bool) var shield_unit = false
export (bool) var can_be_shielded = true
export (int) var gold_dropped = 10
export (int, 1, 20) var damage_to_lives = 1
export (float, 0.0, 1.0) var primary_damage_reduction = 0.75
export (float) var coin_drop_radius = 30.0
export (Dictionary) var resistances = {
	SecondaryDamageType.NORMAL: 100,
	SecondaryDamageType.FIRE: 100,
	SecondaryDamageType.ICE: 100,
	SecondaryDamageType.POISON: 100,
	SecondaryDamageType.HOLY: 100
}

export (PackedScene) var Shield
export (PackedScene) var GoldCoin
export (PackedScene) var SilverCoin
export (PackedScene) var CopperCoin

var coin_amount = {
	"Gold": 50,
	"Silver": 10,
	"Copper": 1
}

var shield_health: int = 0
var max_shield_health: int = 0

var positioning_node
var current_position: Vector2 = Vector2.ZERO
var future_position: Vector2 = Vector2.ZERO

var is_slowed: bool = false
var is_casting: bool = false
var is_spawning: bool = false
var is_shielded: bool = false

var enemy_hitbox: Area2D = null
var state_machine

onready var poison_DOT_node = $PoisonDOT
onready var health_bar = $"%HealthBar"
onready var energy_shield = $EnergyShieldHealth


func _enter_tree() -> void:
	position_target = $PositionTarget
	enemy_hitbox = $Flip/Sprite/Hurtbox


func _ready() -> void:
	health_bar.health_type = health_type
	health_bar.set_textures()
	
	if shield_unit:
		shield()


func _physics_process(delta) -> void:
	if is_dead or is_casting or is_spawning: return
	
	if get_parent().is_class("PathFollow2D"):
		get_parent().offset += speed * delta
	
	if positioning_node:
		positioning_node.offset += speed * delta
		if positioning_node.loop == false and positioning_node.get_unit_offset() == 1.0:
			emit_signal("deplete_level_health", damage_to_lives)
			emit_signal("died")
			self.queue_free()
	
	_orient_enemy()
	current_position = self.position
	
	if is_hurt: return
	
	animation_player.play("Move")


# Takes damage
func take_damage(var damage_taken: int = 10, var type: int = PrimaryDamageType.PHYSICAL) -> void:
	if is_dead: return
	
	if health_type == type:
		damage_taken = int(float(damage_taken) * primary_damage_reduction)
	
	if is_shielded:
		energy_shield.set_current_hp(energy_shield.current_hp - damage_taken)
	else:
		health.set_current_hp(health.current_hp - damage_taken)
	
	if health.current_hp <= 0: return
	if is_attacking: return
	
	animation_player.play("Hurt")
	is_hurt = true
	yield(animation_player, "animation_finished")
	is_hurt = false


# Heals the unit
func heal(var heal_amount: int = 10) -> void:
	if is_dead: return
	health.set_current_hp(health.current_hp + heal_amount)


# Shields the unit
func shield(var shield_amount: int = 50) -> void:
	if is_shielded and not can_be_shielded: return
	
	energy_shield.set_current_hp(shield_amount)
	energy_shield.set_max_hp(shield_amount)
	
	var shield = Shield.instance()
	self.add_child(shield)
	is_shielded = true
	
	$"%EnergyBar".set_visible(true)
	$"%HealthBar".set_visible(false)


# Kills the unit
func die() -> void:
	if is_dead: return
	
	is_dead = true
	emit_signal("died")
	
	health_bar.set_visible(false)
	_drop_coins()
	enemy_hitbox.queue_free()
	
	if self.has_node("SlowAreaParticles"):
		self.get_node("SlowAreaParticles").queue_free()
		is_slowed = false
	
	if poison_DOT_node.is_inflicted:
		poison_DOT_node.is_inflicted = false
	
	animation_player.play("Death")
	yield(animation_player, "animation_finished")
	
	remove_body_timer.start()
	yield(remove_body_timer, "timeout")
	
	self.queue_free()


func _drop_coins() -> void:
	var gold_to_drop = gold_dropped
	
	while gold_to_drop > 0:
		if gold_to_drop >= coin_amount["Gold"]:
			var gold_coin = GoldCoin.instance()
			var coin_position = _get_random_surrounding_position()
			_spawn_coin(gold_coin, coin_position)
			gold_to_drop -= coin_amount["Gold"]
		elif gold_to_drop >= coin_amount["Silver"]:
			var silver_coin = SilverCoin.instance()
			var coin_position = _get_random_surrounding_position()
			_spawn_coin(silver_coin, coin_position)
			gold_to_drop -= coin_amount["Silver"]
		elif gold_to_drop >= coin_amount["Copper"]:
			var copper_coin = CopperCoin.instance()
			var coin_position = _get_random_surrounding_position()
			_spawn_coin(copper_coin, coin_position)
			gold_to_drop -= coin_amount["Copper"]


func _spawn_coin(var coin, var coin_position: Vector2) -> void:
	var y_sort = get_parent().get_parent()
	coin.global_position = coin_position
	y_sort.call_deferred("add_child", coin)


func _get_random_surrounding_position() -> Vector2:
	var x_position = self.global_position.x + rand_range(-coin_drop_radius, coin_drop_radius)
	var y_position = self.global_position.y + rand_range(-coin_drop_radius, coin_drop_radius)
	return Vector2(x_position, y_position)


func _orient_enemy() -> void:
	if self.position.x > current_position.x and not facing_right or \
			self.position.x < current_position.x and facing_right:
		_flip_unit()


func _on_EnergyShieldHealth_hp_depleted() -> void:
	is_shielded = false
	$"%EnergyBar".set_visible(false)
	$"%HealthBar".set_visible(true)
	
	if self.has_node("Shield"):
		$Shield.queue_free()
