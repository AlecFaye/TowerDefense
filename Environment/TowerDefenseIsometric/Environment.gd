tool
extends TileMap

export (Vector2) var regular_offset = Vector2(-192, -267)  # Vector2(-192, -276)

export (bool) var UpdateOffsets setget _update_offsets


func _ready() -> void:
	_update_offsets()


func get_cell_global_position(var given_position: Vector2) -> Vector2:
	return to_global(map_to_world(world_to_map(to_local(given_position))))


func is_valid_hover(var mouse_position: Vector2) -> bool:
	var local_position = self.to_local(mouse_position)
	var tile_position = self.world_to_map(local_position)
	var tile_id = self.get_cellv(tile_position)
	return tile_id != -1 and (self.tile_set.tile_get_name(tile_id) == "TileDefault" or self.tile_set.tile_get_name(tile_id) == "TileSnowDefault")


func _update_offsets(var _new = null) -> void:
	for tile_id in tile_set.get_tiles_ids():
		tile_set.tile_set_texture_offset(tile_id, regular_offset)
