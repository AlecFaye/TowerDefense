extends KinematicBody2D

const DISTANCE_EPSILON: int = 5

export (int) var speed = 200
export (float) var translucent_factor = 0.60

var velocity: Vector2 = Vector2()
var facing_right: bool = true
var is_slowed: bool = false
var is_hurt: bool = false

var can_be_hurt: bool = true

var state_machine
var level

onready var target = self.position
onready var flip = $Flip
onready var sprite = $Flip/Sprite
onready var animation_player = $AnimationPlayer
onready var hurt_reset_timer = $HurtResetTimer


func _ready() -> void:
	state_machine = $AnimationTree.get("parameters/playback")
	level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)


func _input(event):
	if level.selected_unit: return
	
	if event.is_action_pressed("deselect"):
		target = get_global_mouse_position()
		_orient()


func _physics_process(_delta):
	if is_hurt: 
		if state_machine.get_current_node() == "Idle":
			is_hurt = false
			hurt_reset_timer.start()
		return
	
	velocity = position.direction_to(target) * speed
	
	if position.distance_to(target) > DISTANCE_EPSILON:
		state_machine.travel("Run")
		velocity = move_and_slide(velocity)
	else:
		state_machine.travel("Idle")


func take_damage(var _damage_amount: int = 1, var _damage_type: int = 0) -> void:
	if not can_be_hurt: return
	
	state_machine.travel("Hurt")
	level.deplete_level_health(1)
	sprite.set_self_modulate(Color(1, 1, 1, translucent_factor))

	can_be_hurt = false
	is_hurt = true


func _orient() -> void:
	if (target.x < self.position.x and facing_right) or \
			(target.x > self.position.x and not facing_right):
		flip.scale.x = -flip.scale.x
		facing_right = not facing_right


func _on_HurtResetTimer_timeout() -> void:
	can_be_hurt = true
	sprite.set_self_modulate(Color(1, 1, 1, 1))
