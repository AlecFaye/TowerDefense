extends Node2D

signal finished_building_path

const PORTAL_OPEN_TIME: float = 0.5
const DEFAULT_TILE: String = "TileDefault"
const DEFAULT_SNOW_TILE: String = "SnowTileDefault"

enum Wave {
	EnemyFilePath,
	Route,
	NextSpawnTime
}

enum BuildInfo {
	POSITION,
	TILE
}

export (int) var starting_gold = 1000
export (int) var max_lives = 10
export (String, 
		"None", 
		"FireMage", 
		"Mushroom",
		"Priest", 
		"Rogue",
		"Alchemist") var unit_unlocked_after_level_completed = "None"
export (PackedScene) var SpawnPortal

export (float) var place_tile_time = 0.25
export (Array, int) var paths_to_activate = []
export (Array, int) var activate_path_on_wave = []
export (Dictionary) var tile_updates = {}

# Enemy Path, Route Number, Spawn Time, Is Last Unit
var waves: Dictionary = {}
var path_index_to_activate: int = 0
var current_wave: int = 0
var enemies_killed: int = 0
var total_enemies: int = 999

var placed_towers: Array = []
var open_spaces: Array = []
var placeable_tiles: Dictionary = {
	"TileStraightN": 0,
	"TileStraightW": 0,
	"TileSplitN": 0,
	"TileSplitS": 0,
	"TileSplitE": 0,
	"TileSplitW": 0,
	"TileCornerSquareN": 0,
	"TileCornerSquareS": 0,
	"TileCornerSquareE": 0,
	"TileCornerSquareW": 0,
	"TileCrossingN": 0,
	"TileRiverBridgeN": 0,
	"TileRiverBridgeW": 0,
	"SnowTileStraightN": 0,
	"SnowTileStraightW": 0,
	"SnowTileSplitN": 0,
	"SnowTileSplitS": 0,
	"SnowTileSplitE": 0,
	"SnowTileSplitW": 0,
	"SnowTileCornerSquareN": 0,
	"SnowTileCornerSquareS": 0,
	"SnowTileCornerSquareE": 0,
	"SnowTileCornerSquareW": 0,
	"SnowTileCrossingN": 0,
	"SnowTileRiverBridgeN": 0,
	"SnowTileRiverBridgeW": 0
}
var selected_unit = null
var selected_unit_on_map = null

var hover_icon_scale = Vector2(1.5, 1.5)
var hovered_position: Vector2 = Vector2.ZERO

var valid_hover: bool = false
var mouse_in_gui: bool = false
var is_spawning_enemies: bool = false

var completed_level: bool = false
var failed_level: bool = false
var is_tower_info_popup: bool = false
var is_level_paused: bool = false

var paths = null
var enemy_routes = null
var effect_routes = null

onready var health = $Health
onready var gold = $Gold
onready var environment_tilemap = $Tilesets/Environment
onready var details_tilemap = $Tilesets/Details
onready var castle_tilemap = $CastleSort/Castle
onready var hovered_sprite = $MainYSort/HoverTileContainer/HoveredTile
onready var tower_container = $MainYSort/TowerContainer
onready var enemy_container = $MainYSort/EnemyContainer

onready var level_GUI = $LevelGUI
onready var unit_selector = $LevelGUI/UnitSelector
onready var start_wave_button = $StartWaveButton
onready var level_info_UI = $LevelInfoUI


func _ready() -> void:
	$"%CatPlayer".cat_name = WorldVariables.cat_name
	paths = $MapPaths.get_children()
	
	gold.set_current_gold(starting_gold)
	level_info_UI.update_gold(gold.current_gold)
	
	health.set_max_hp(max_lives)
	health.set_current_hp(max_lives)
	level_info_UI.update_lives(health.current_hp)
	
	_get_open_spaces()
	
	_load_tower_info()
	_load_placeable_tiles()
	_load_paths()
	_load_wave_info()
	
	level_info_UI.update_waves(1, waves.size())


func _physics_process(_delta) -> void:
	if failed_level or completed_level or is_tower_info_popup: return
	_check_valid_hover()
	_check_win_conditions()


func _input(event) -> void:
	if failed_level or completed_level or is_tower_info_popup: return
	
	if selected_unit:
		var cell = environment_tilemap.world_to_map(get_global_mouse_position())
		var is_cell_taken = _check_if_is_cell_taken(cell)
		
		if event.is_action_released("select") and valid_hover and \
				not mouse_in_gui and cell in open_spaces and \
				not is_cell_taken and withdraw_gold(selected_unit["BaseCost"]):
			_place_tower(cell)
			_clear_hover_sprite()
		elif event.is_action_released("deselect"):
			_clear_hover_sprite()
			selected_unit = null
	else:
		var cell = environment_tilemap.world_to_map(get_global_mouse_position())
		if event.is_action_released("select"):
			for tower_info in placed_towers:
				if tower_info["CellPosition"] == cell:
					var tower = tower_info["Tower"]
					tower.display_target_range(true)
					_display_selected_unit_info(tower)
		elif event.is_action_released("deselect"):
			selected_unit_on_map = null


func _unhandled_input(event: InputEvent) -> void:
	if failed_level or completed_level or is_tower_info_popup or is_level_paused: return
	
	if event.is_action_pressed("ui_cancel"):
		is_level_paused = true
		$"%LevelPausedPopup".popup()
	elif event.is_action_pressed("unit_1"):
		unit_selector.select_unit(0)
	elif event.is_action_pressed("unit_2"):
		unit_selector.select_unit(1)
	elif event.is_action_pressed("unit_3"):
		unit_selector.select_unit(2)
	elif event.is_action_pressed("unit_4"):
		unit_selector.select_unit(3)
	elif event.is_action_pressed("unit_5"):
		unit_selector.select_unit(4)


func killed_enemy() -> void:
	enemies_killed += 1


func pause_towers() -> void:
	for placed_tower in placed_towers:
		var tower = placed_tower["Tower"]
		tower.pause_timers()


func unpause_towers() -> void:
	for placed_tower in placed_towers:
		var tower = placed_tower["Tower"]
		tower.unpause_timers()


func deposit_gold(var gold_amount: int) -> void:
	gold.set_current_gold(gold.current_gold + gold_amount)
	level_info_UI.update_gold(gold.current_gold)


func withdraw_gold(var gold_amount: int) -> bool:
	if gold.current_gold < gold_amount: 
		return false
	
	gold.set_current_gold(gold.current_gold - gold_amount)
	level_info_UI.update_gold(gold.current_gold)
	return true


func deplete_level_health(var damage: int) -> void:
	health.set_current_hp(health.current_hp - damage)
	level_info_UI.update_lives(health.current_hp)


func remove_tower(var cell: Vector2) -> void:
	for tower in placed_towers:
		if tower["CellPosition"] == cell:
			placed_towers.erase(tower)


func set_selected_unit(var unit: Dictionary) -> void:
	_clear_hover_sprite()
	selected_unit = unit
	var hover_icon = load("res://UI/AnimatedIcons/%sIcon.tscn" % unit["FilePath"]).instance()
	hovered_sprite.add_child(hover_icon)
	hover_icon.initialize(hover_icon_scale, unit["TowerStats"][0]["Range"])


func _check_win_conditions() -> void:
	if is_spawning_enemies and enemies_killed >= total_enemies:
		if current_wave < waves.size():
			pause_towers()
			start_wave_button.set_visible(true)
			is_spawning_enemies = false
		else:
			_complete_level()


func _spawn_enemies() -> void:
	if paths.size() == 0: return
	is_spawning_enemies = true
	
	var wave = waves["Wave %s" % str(current_wave)]
	enemies_killed = 0
	total_enemies = wave.size()
	
	if path_index_to_activate < paths_to_activate.size() and current_wave == activate_path_on_wave[path_index_to_activate]:
		var path_to_activate = paths_to_activate[path_index_to_activate]
		paths[path_to_activate].activate()
		
		var path_to_build = _add_path(path_to_activate)
		_build_path(path_to_build)
		path_index_to_activate += 1
		
		yield(self, "finished_building_path")
	
	for index in range(wave.size()):
		var info = wave[index]
		var file_path = info[Wave.EnemyFilePath]
		var route = info[Wave.Route]
		var spawn_time = info[Wave.NextSpawnTime]
		var enemy = load("res://Units/Enemies/%s/%s.tscn" % [file_path, file_path]).instance()
		
		var portal = SpawnPortal.instance()
		var spawn = $MapPaths.get_child(route).get_child(0)
		portal.global_position = Vector2(0, -environment_tilemap.get_cell_size().y / 3)
		spawn.add_child(portal)
		yield(get_tree().create_timer(PORTAL_OPEN_TIME, false), "timeout")
		
		var enemy_curve = Curve2D.new()
		for point in paths[route].get_children():
			enemy_curve.add_point(point.position)
		
		enemy_routes[route].curve = enemy_curve
		
		enemy.connect("deplete_level_health", self, "deplete_level_health")
		enemy.connect("died", self, "killed_enemy")
		enemy_container.add_child(enemy)
		
		var enemy_node_path = enemy.get_path()
		var new_path_follow = PathFollow2D.new()
		new_path_follow.rotate = false
		new_path_follow.loop = false
		
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = enemy_node_path
		new_path_follow.add_child(remote_transform)
		
		enemy_routes[route].add_child(new_path_follow)
		  
		var positioning_node_path = get_node(new_path_follow.get_path())
		enemy.positioning_node = positioning_node_path
		
		yield(get_tree().create_timer(spawn_time, false), "timeout")


func _add_path(var path_index: int) -> Array:
	var build_paths = []
	var level_path: Array = $MapPaths.get_child(path_index).get_children()
	
	for index in range(level_path.size() - 1):
		var point_one: Vector2 = environment_tilemap.world_to_map(level_path[index].global_position)
		var point_two: Vector2 = environment_tilemap.world_to_map(level_path[index + 1].global_position)
		
		if point_one.x == point_two.x:
			var x = point_one.x
			var y1 = point_one.y
			var y2 = point_two.y
			
			if y2 > y1:
				for y in range(y1, y2 + 1):
					var tile_to_be_added: Array = _get_tile(x, y, "TileStraightN")
					build_paths.append(tile_to_be_added)
			else:
				for y in range(y1, y2 - 1, -1):
					var tile_to_be_added: Array = _get_tile(x, y, "TileStraightN")
					build_paths.append(tile_to_be_added)
		elif point_one.y == point_two.y:
			var y = point_one.y
			var x1 = point_one.x
			var x2 = point_two.x
			
			if x2 > x1:
				for x in range(x1, x2 + 1):
					var tile_to_be_added: Array = _get_tile(x, y, "TileStraightW")
					build_paths.append(tile_to_be_added)
			else:
				for x in range(x1, x2 - 1, -1):
					var tile_to_be_added: Array = _get_tile(x, y, "TileStraightW")
					build_paths.append(tile_to_be_added)
	return build_paths


func _get_tile(var x: int, var y: int, var tile_name: String) -> Array:
	var tile_id = placeable_tiles[tile_name]
	var tile = Vector2(x, y)
	var default_tile_id = environment_tilemap.get_cellv(tile)
	var default_tile_name = environment_tilemap.get_tileset().tile_get_name(default_tile_id)
	
	if "Snow" in default_tile_name:
		tile_id = placeable_tiles["Snow%s" % tile_name]
	
	if tile in tile_updates:
		var updated_tile = tile_updates[tile]
		tile_id = placeable_tiles[updated_tile]
	return [tile, tile_id]


func _place_tower(var cell: Vector2) -> void:
	var tower = load("res://Units/Towers/%s/%s.tscn" % [selected_unit["FilePath"], selected_unit["FilePath"]]).instance()
	
	tower.global_position = Vector2(hovered_position.x, hovered_position.y + environment_tilemap.get_cell_size().y / 2)
	tower_container.add_child(tower)
	tower.initialize(selected_unit["TowerStats"][0]["Range"], cell)
	
	placed_towers.append({"Tower": tower, "CellPosition": cell})
	
	selected_unit = null


func _display_selected_unit_info(var tower_info) -> void:
	is_tower_info_popup = true
	selected_unit_on_map = tower_info
	$"%TowerInfoPopup".display_tower_info(selected_unit_on_map)


func _check_valid_hover() -> void:
	valid_hover = environment_tilemap.world_to_map(get_global_mouse_position()) in open_spaces
	mouse_in_gui = _is_mouse_in_gui()
	
	hovered_sprite.set_visible(valid_hover and not mouse_in_gui)
	if not valid_hover or mouse_in_gui: return
	
	hovered_position = environment_tilemap.get_cell_global_position(get_global_mouse_position())
	hovered_sprite.global_position = hovered_position


func _check_if_is_cell_taken(var cell: Vector2) -> bool:
	for tower_info in placed_towers:
		if cell == tower_info["CellPosition"]:
			return true
	return false


func _check_if_enemies_left() -> bool:
	for enemy in enemy_container.get_children():
		if not enemy.is_dead:
			return true
	return false


func _clear_hover_sprite() -> void:
	for node in hovered_sprite.get_children():
		node.queue_free()


func _is_mouse_in_gui() -> bool:
	var mouse_position = get_global_mouse_position()
	
	for gui_node in level_GUI.get_children():
		if mouse_position.x > gui_node.rect_global_position.x and mouse_position.y > gui_node.rect_global_position.y \
				and mouse_position.x < gui_node.rect_global_position.x + gui_node.rect_size.x \
				and mouse_position.y < gui_node.rect_global_position.y + gui_node.rect_size.y:
			return true
	return false


func _get_open_spaces() -> void:
	var environment_tileset: TileSet = environment_tilemap.get_tileset()
	
	var default_tile_id: int = -1
	var default_snow_tile_id: int = -1
	
	for id in environment_tileset.get_tiles_ids():
		if environment_tileset.tile_get_name(id) == DEFAULT_TILE:
			default_tile_id = id
		elif environment_tileset.tile_get_name(id) == DEFAULT_SNOW_TILE:
			default_snow_tile_id = id
	
	open_spaces = environment_tilemap.get_used_cells_by_id(default_tile_id)
	open_spaces.append_array(environment_tilemap.get_used_cells_by_id(default_snow_tile_id))
	
	for cell in details_tilemap.get_used_cells():
		open_spaces.erase(cell)
	
	for cell in castle_tilemap.get_used_cells():
		open_spaces.erase(cell)


func _load_tower_info() -> void:
	for unit in WorldVariables.tower_info:
		unit_selector.add_unit(unit)


func _load_placeable_tiles() -> void:
	var tileset = environment_tilemap.get_tileset()
	var tile_ids = tileset.get_tiles_ids()
	
	for tile in placeable_tiles:
		for tile_id in tile_ids:
			if tileset.tile_get_name(tile_id) == "Path%s" % tile:
				placeable_tiles[tile] = tile_id


func _complete_level() -> void:
	completed_level = true
	
	if unit_unlocked_after_level_completed != "None":
		_unlock_next_unit()
	_unlock_next_level()
	
#	WorldVariables.save_level_info()
	
	$"%LevelCompletedPopup".popup()


func _unlock_next_level() -> void:
	var game_levels = WorldVariables.game_levels
	for index in game_levels.size():
		var level = game_levels[index]
		if index == WorldVariables.level_index:
			level["LevelCompleted"] = true
			if index + 1 < game_levels.size():
				var next_level = game_levels[index + 1]
				next_level["LevelUnlocked"] = true


func _unlock_next_unit() -> void:
	for tower in WorldVariables.tower_info:
		if tower["Name"] == unit_unlocked_after_level_completed:
			tower["Unlocked"] = true


func _fail_level() -> void:
	$"%LevelFailedPopup".popup()
	failed_level = true
	self.set_physics_process(false)


func _build_path(var path_to_build: Array) -> void:
	for path in path_to_build:
		var cell = path[BuildInfo.POSITION]
		var tile_id = path[BuildInfo.TILE]
		environment_tilemap.set_cellv(cell, tile_id)
		details_tilemap.set_cellv(cell, -1)
		yield(get_tree().create_timer(place_tile_time, false), "timeout")
	emit_signal("finished_building_path")


func _load_paths() -> void:
	enemy_routes = []
	effect_routes = []
	
	for _count in paths.size():
		var enemy_path = Path2D.new()
		$EnemyRoutes.add_child(enemy_path)
		enemy_routes.append(enemy_path)
		
		var effect_path = Path2D.new()
		$EffectRoutes.add_child(effect_path)
		effect_routes.append(effect_path)


func _load_wave_info() -> void:
	var file = File.new()
	file.open("res://Data/Levels/LevelInfo.json", file.READ)
	
	var text = file.get_as_text()
	var level_info_dict = {}
	level_info_dict = parse_json(text)
	file.close()
	
	for level_info in level_info_dict.values():
		if level_info["FilePath"] == self.name:
			waves = level_info["Waves"]


func _on_TowerInfoPopup_popup_hide():
	is_tower_info_popup = false


func _on_LevelPausedPopup_unpause() -> void:
	is_level_paused = false


func _on_PauseButton_button_up() -> void:
	is_level_paused = true
	$"%LevelPausedPopup".popup()


func _on_StartWaveButton_button_up():
	current_wave += 1
	
	if current_wave > waves.size(): 
		return
	
	unpause_towers()
	start_wave_button.set_visible(false)
	level_info_UI.update_waves(current_wave, waves.size())
	_spawn_enemies()
