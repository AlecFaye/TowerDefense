tool
extends TileMap

export (Vector2) var offset = Vector2(-192, -267)

export (bool) var UpdateOffsets setget _update_offsets


func _ready() -> void:
	_update_offsets()


func _update_offsets(var _new = null) -> void:
	for tile_id in tile_set.get_tiles_ids():
		tile_set.tile_set_texture_offset(tile_id, offset)
