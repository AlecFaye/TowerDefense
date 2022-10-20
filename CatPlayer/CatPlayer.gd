extends KinematicBody2D

const DISTANCE_EPSILON: int = 5

export (int) var speed = 200
export (String,
		"Cleopatra",
		"Jupiter",
		"Kurai",
		"Loki",
		"Luna") var cat_name = "Cleopatra"

var velocity: Vector2 = Vector2()
var facing_right: bool = true

var level

onready var target = self.position
onready var flip = $Flip
onready var sprite = $Flip/Sprite
onready var animation_player = $AnimationPlayer


func _ready() -> void:
	level = get_tree().get_root().get_child(WorldVariables.LEVEL_SCENE_INDEX)


func _input(event):
	if level.selected_unit: return
	
	if event.is_action_pressed("deselect"):
		target = get_global_mouse_position()
		_orient()
	elif event.is_action_pressed("select"):
		animation_player.play("%s - Attack" % cat_name)


func _physics_process(_delta):
	velocity = position.direction_to(target) * speed
	
	if position.distance_to(target) > DISTANCE_EPSILON:
		animation_player.play("%s - Run" % cat_name)
		velocity = move_and_slide(velocity)
	else:
		if not "Attack" in animation_player.get_current_animation():
			animation_player.play("%s - Idle" % cat_name)


func _orient() -> void:
	if (target.x < self.position.x and facing_right) or \
			(target.x > self.position.x and not facing_right):
		flip.scale.x = -flip.scale.x
		facing_right = not facing_right
