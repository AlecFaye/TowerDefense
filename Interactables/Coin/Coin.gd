extends Area2D

const DRAG := 14.0

export (int) var gold_amount: int = 10

var max_speed := 300.0
var _velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	var attractors = []
	
	for attractor in get_overlapping_areas():
		if attractor.is_in_group("CoinAttractor"):
			attractors.append(attractor)
	
	if attractors:
		var desired_velocity: Vector2 = ((attractors[0].global_position - global_position).normalized() * max_speed)
		var steering := desired_velocity - _velocity
		_velocity += steering / DRAG
	else:
		_velocity = Vector2.ZERO
	
	position += _velocity * delta


func set_gold_amount(var new_gold_amount: int) -> void:
	gold_amount = new_gold_amount


func _on_Coin_area_entered(area: Area2D) -> void:
	if area.is_in_group("CoinGrabber"):
		var level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)
		if level.has_method("deposit_gold"):
			level.deposit_gold(gold_amount)
		self.queue_free()
