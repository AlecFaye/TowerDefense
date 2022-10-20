extends "res://Units/Enemies/Enemy.gd"
#
#export (int) var max_spawned_units = 3
#export (float) var casting_time = 10.0
#
#export (Array, PackedScene) var spawn_units
#
#var directions = {
#	"N":  Vector2.UP,
#	"NE": Vector2(1, -1),
#	"E":  Vector2.RIGHT,
#	"SE": Vector2(1, 1),
#	"S":  Vector2.DOWN,
#	"SW": Vector2(-1, 1),
#	"W":  Vector2.LEFT,
#	"NW": Vector2(-1, -1)
#}
#
#var tile_size: Vector2 = Vector2(64, 32)
#var post_spawn_positions: Array = []
#var post_position: Vector2 = Vector2.ZERO
#var possible_post_positions_around_paladin: Array = []
#var spawn_count: int = 0
#
#var level_node = null
#
#onready var casting_timer = $Timers/CastingTimer
#
#
#func _ready() -> void:
#	casting_timer.set_wait_time(casting_time)
#	casting_timer.start()
#	animation_player.play("Castloop")
#
#
#func _draw():
#	level_node = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)
#	possible_post_positions_around_paladin = _get_possible_post_positions()
#	post_position = _get_first_available_post()
#	post_spawn_positions = _set_up_spawn_positions()
#
#
#func _get_possible_post_positions() -> Array:
#	var positions = []
#	for direction in directions.values():
#		var possible_post = Vector2(cell_position.x + direction.x, cell_position.y + direction.y)
#		var tile_name = ""
#		var tile_id = level_node.environment_tilemap.get_cellv(possible_post)
#
#		if tile_id != -1:
#			tile_name = level_node.environment_tilemap.get_tileset().tile_get_name(tile_id)
#		if tile_name.begins_with("Path"):
#			positions.append(possible_post)
#	return positions
#
#
#func _get_first_available_post() -> Vector2:
#	if possible_post_positions_around_paladin.size() == 0:
#		return Vector2.ZERO
#	var cell = possible_post_positions_around_paladin[0]
#	var world_position = level_node.environment_tilemap.map_to_world(cell)
#	world_position = Vector2(world_position.x, world_position.y + tile_size.y)
#	return world_position
#
#
#func _set_up_spawn_positions() -> Array:
#	var positions = []
#	var north_position = Vector2(post_position.x, post_position.y - tile_size.y / 2)
#	var south_west_position = Vector2(post_position.x - tile_size.x / 2, post_position.y + tile_size.y / 2)
#	var south_east_position = Vector2(post_position.x + tile_size.x / 2, post_position.y + tile_size.y / 2)
#
#	positions.append({
#			"Position": north_position,
#			"Unit": null,
#			"Spawned": false
#		})
#	positions.append({
#			"Position": south_west_position,
#			"Unit": null,
#			"Spawned": false
#		})
#	positions.append({
#			"Position": south_east_position,
#			"Unit": null,
#			"Spawned": false
#		})
#
#	return positions
#
#
#func _spawn_unit() -> void:
#	if spawn_count >= max_spawned_units or possible_post_positions_around_paladin.size() == 0: 
#		return
#
#	var spawn = _get_first_available_spawn_point()
#	var random_unit_index = randi() % spawn_units.size()
#	var unit = spawn_units[random_unit_index].instance()
#
#	unit.global_position = self.global_position
#	unit.set_as_toplevel(true)
#	spawn["Spawned"] = true
#	spawn["Unit"] = unit
#	self.add_child(unit)
#	unit.post.global_position = spawn["Position"]
#	unit.move_to_post()
#
#	spawn_count += 1
#
#
#func _get_first_available_spawn_point() -> Dictionary:
#	for spawn_point in post_spawn_positions:
#		if spawn_point["Spawned"] == false:
#			return spawn_point
#	return {}
#
#
#func _on_CastingTimer_timeout():
#	animation_player.play("Spellcast")
#
#
#func _on_AnimationPlayer_animation_finished(anim_name):
#	match anim_name:
#		"Spellcast":
#			_spawn_unit()
#			casting_timer.set_wait_time(casting_time)
#			casting_timer.start()
#			animation_player.play("Castloop")
