extends "res://Units/Unit.gd"

const NO_ABILITY: int = -1
const MIN_LEVEL: int = 1
const MAX_LEVEL: int = 7

enum Targeting {FIRST, LAST, CLOSE}
enum AbilityNumber {FIRST, SECOND, THIRD}

export (Targeting) var target_type
export (PrimaryDamageType) var damage_type

var targeting_area: Area2D = null

var unit_level: int = MIN_LEVEL
var cell_position: Vector2 = Vector2.ZERO
var world_position: Vector2 = Vector2.ZERO

var target_range: int = 1

var abilities: Array = []
var stats: Array = []

var sell_amount: int = 100
var upgrade_amount: int = 250

var attack_timers = []
var paused_timers = []


func initialize(var _range: int, var cell: Vector2) -> void:
	target_range = _range
	cell_position = cell
	world_position = self.global_position
	targeting_area = $TargetingArea
	targeting_area.start(_range)
	
	_get_stats()
	_set_stats()
	
	_get_abilities()
	_connect_attack_timers()
	_reset_ability_cooldowns()
	_set_ability_locks()


func display_target_range(var is_visible: bool = true) -> void:
	targeting_area.get_node("VisibleRange").set_visible(is_visible)


func increase_level() -> void:
	unit_level = int(clamp(unit_level + 1, MIN_LEVEL, MAX_LEVEL))
	_set_stats()
	_set_ability_locks()
	_reset_ability_cooldowns()
	_reset_attack_timers()
	targeting_area.start(target_range)


# Pause attack timers
func pause_timers() -> void:
	for timer in attack_timers:
		if not timer.is_stopped():
			timer.set_paused(true)
			paused_timers.append(timer)


# Unpause attack timers
func unpause_timers() -> void:
	for timer in paused_timers:
		timer.set_paused(false)
	paused_timers.clear()


# Create and connect attack timers
func _connect_attack_timers() -> void:
	for index in range(abilities.size()):
		var ability = abilities[index]
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout", self, "_on_AttackTimer_timeout", [index])
		timer.set_wait_time(ability["AbilityStats"][unit_level - 1]["Cooldown"])
		$AttackTimers.add_child(timer)
		attack_timers.append(timer)


# Get the stats of the tower
func _get_stats() -> void:
	for tower in WorldVariables.tower_info:
		if tower["FilePath"] == unit_type:
			stats = tower["TowerStats"]


# Gets the abilities of the tower
func _get_abilities() -> void:
	for tower in WorldVariables.tower_info:
		if tower["FilePath"] == unit_type:
			abilities = tower["Abilities"].duplicate(true)


 # Set the stat of the tower based on the unit's level
func _set_stats() -> void:
	var stat = stats[unit_level - 1]
	
	target_range = stat["Range"]
	sell_amount = stat["Sell"]
	upgrade_amount = stat["Upgrade"]


# Set ability locks
func _set_ability_locks() -> void:
	for ability in abilities:
		ability["AbilityUnlocked"] = unit_level >= ability["LevelUnlocked"]


# Reset the ability cooldowns when a new tower is instanced
func _reset_ability_cooldowns() -> void:
	for ability in abilities:
		ability["OnCooldown"] = false


# Reset the timers based on unit's level
func _reset_attack_timers() -> void:
	for index in range(abilities.size()):
		var ability = abilities[index]
		var timer = attack_timers[index]
		timer.stop()
		timer.set_wait_time(ability["AbilityStats"][unit_level - 1]["Cooldown"])


# Starts the specified ability's cooldown
func _start_ability_cooldown(var ability_number: int) -> void:
	var ability = abilities[ability_number]
	var timer = attack_timers[ability_number]
	ability["OnCooldown"] = true
	timer.start()


# Checks if all abilities are on cooldown
func _all_abilities_on_cooldown() -> bool:
	for ability in abilities:
		if ability["AbilityUnlocked"] and not ability["OnCooldown"]:
			return false
	return true


func _select_ability() -> int:
	for index in range(abilities.size() - 1, -1, -1):
		var ability = abilities[index]
		if ability["AbilityUnlocked"] and not ability["OnCooldown"]:
			return index
	return -1


# Checks if the enemy is in range
func _is_enemy_in_range() -> bool:
	target = null
	var min_distance: int = 999999
	
	for body in targeting_area.get_overlapping_bodies():
		if not body.is_in_group("Enemy"): 
			continue
		
		var enemy = body
		if enemy.is_dead: 
			continue
		
		if target == null:
			target = enemy
			continue
		
		match target_type:
			Targeting.FIRST:
				if enemy.positioning_node.get_unit_offset() > target.positioning_node.get_unit_offset():
					target = enemy
			Targeting.LAST:
				if enemy.positioning_node.get_unit_offset() < target.positioning_node.get_unit_offset():
					target = enemy
			Targeting.CLOSE:
				var distance = self.global_position.distance_to(enemy.global_position)
				if distance < min_distance:
					target = enemy
					min_distance = distance
	return target != null


# Orients the enemy
func _orient_unit(var target_position) -> void:
	if target_position == null: return
	
	if self.global_position.x < target_position.x and not facing_right:
		_flip_unit()
	elif self.global_position.x > target_position.x and facing_right:
		_flip_unit()


func _on_AttackTimer_timeout(var ability_number: int) -> void:
	var ability = abilities[ability_number]
	ability["OnCooldown"] = false
