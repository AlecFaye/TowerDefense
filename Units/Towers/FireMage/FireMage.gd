extends "res://Units/Towers/Tower.gd"

const CAST_SPELL_TIME: float = 0.9

export (Vector2) var fireball_offset = Vector2(0, -40)
export (Vector2) var meteor_scale = Vector2(2, 2)

export (int) var firestorm_loop_count = 1024

export (PackedScene) var Fireball
export (PackedScene) var MeteorShower
export (PackedScene) var Firestorm

var level_paths = null
var effect_routes = null


func _enter_tree() -> void:
	targeting_area = $TargetingArea


func _ready() -> void:
	var level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)
	level_paths = level.paths
	effect_routes = level.effect_routes


func _physics_process(_delta) -> void:
	if is_attacking or is_hurt or is_dead: return
	
	var is_enemy_in_range = _is_enemy_in_range()
	var are_abilities_on_cd = _all_abilities_on_cooldown()
	
	if is_enemy_in_range:
		if not are_abilities_on_cd:
			_orient_unit(target.global_position)
			_attack()
		else:
			animation_player.play("Idle")
	else:
		animation_player.play("Idle")


func _attack() -> void:
	var ability_number = _select_ability()
	if ability_number == NO_ABILITY: 
		return
	
	is_attacking = true
	
	animation_player.play("Casting")
	yield(get_tree().create_timer(CAST_SPELL_TIME, false), "timeout")
	if target.is_dead:
		_is_enemy_in_range()
	_cast_ability(ability_number)
	yield(animation_player, "animation_finished")
	_start_ability_cooldown(ability_number)
	is_attacking = false


func _cast_ability(var ability_number: int) -> void:
	match ability_number:
		AbilityNumber.FIRST:
			_cast_fireball()
		AbilityNumber.SECOND:
			_cast_meteor_shower()
		AbilityNumber.THIRD:
			_cast_firestorm()


func _cast_fireball() -> void:
	var fireball = Fireball.instance()
	var fireball_position = Vector2(self.global_position.x + fireball_offset.x, self.global_position.y + fireball_offset.y)
	var damage = abilities[AbilityNumber.FIRST]["AbilityStats"][unit_level - 1]["Damage"]
	
	if not facing_right:
		fireball.scale.x = -fireball.scale.x
	fireball.facing_right = facing_right
	fireball.start(fireball_position, target)
	fireball.set_as_toplevel(true)
	self.add_child(fireball)
	
	fireball.set_damage(damage)
	fireball.set_damage_type(damage_type)


func _cast_meteor_shower() -> void:
	var meteor_shower = MeteorShower.instance()
	var damage = abilities[AbilityNumber.SECOND]["AbilityStats"][unit_level - 1]["Damage"]
	
	meteor_shower.set_as_toplevel(true)
	meteor_shower.set_scale(meteor_scale)
	meteor_shower.global_position = target.global_position
	self.add_child(meteor_shower)
	
	meteor_shower.set_damage(damage)
	meteor_shower.set_damage_type(damage_type)


func _cast_firestorm() -> void:
	for index in range(level_paths.size()):
		if not level_paths[index].is_active:
			return
		
		var firestorm = Firestorm.instance()
		var damage = abilities[AbilityNumber.THIRD]["AbilityStats"][unit_level - 1]["Damage"]
		firestorm.loop_time = firestorm_loop_count
		
		var firestorm_curve = Curve2D.new()
		var path = level_paths[index].get_children()
		for point_index in range(path.size() - 1, -1, -1):
			var point = path[point_index]
			firestorm_curve.add_point(point.position)
		effect_routes[index].curve = firestorm_curve
		
		self.add_child(firestorm)
		firestorm.set_damage(damage)
		firestorm.set_damage_type(damage_type)
		
		var firestorm_node_path = firestorm.get_path()
		var new_path_follow = PathFollow2D.new()
		new_path_follow.rotate = false
		new_path_follow.loop = false
		
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = firestorm_node_path
		new_path_follow.add_child(remote_transform)
		
		effect_routes[index].add_child(new_path_follow)
		
		var positioning_node_path = get_node(new_path_follow.get_path())
		firestorm.positioning_node = positioning_node_path
