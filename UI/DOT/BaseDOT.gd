extends Node

export (int) var damage = 2
export (float) var tick_time = 1.0
export (float) var duration_time = 5.0

var is_inflicted: bool = false
var can_take_DOT_damage: bool = false

onready var duration_timer = $DurationTimer
onready var tick_timer = $TickTimer


func _ready() -> void:
	tick_timer.set_wait_time(tick_time)
	duration_timer.set_wait_time(duration_time)


func set_damage(var new_damage: int) -> void:
	damage = new_damage


func start_DOT() -> void:
	duration_timer.stop()
	duration_timer.set_wait_time(duration_time)
	duration_timer.start()
	_start_tick_timer()


func _take_DOT_damage() -> void:
	_unit_take_damage()
	can_take_DOT_damage = false
	tick_timer.start()


func _start_tick_timer() -> void:
	if is_inflicted: return
	is_inflicted = true
	tick_timer.start()


func _unit_take_damage() -> void:
	var unit = get_parent()
	unit.take_damage(damage)


func _on_DurationTimer_timeout():
	is_inflicted = false


func _on_TickTimer_timeout():
	can_take_DOT_damage = true
