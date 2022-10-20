extends "res://Units/Enemies/Enemy.gd"

export (float) var regen_time = 1.0
export (int) var regen_amount = 2

var regen_timer: Timer = null


func _ready() -> void:
	_set_regen_timer()


func _set_regen_timer() -> void:
	regen_timer = Timer.new()
	regen_timer.set_one_shot(false)
	regen_timer.set_wait_time(regen_time)
	regen_timer.set_autostart(true)
	regen_timer.connect("timeout", self, "heal", [regen_amount])
	$Timers.add_child(regen_timer)
