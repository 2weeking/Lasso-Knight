extends CharacterBody2D

@export var move_speed : float = 150.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var rope = $Rope
@onready var rope_handle = $RopeHandle

var whipped = false

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if Input.is_action_just_pressed("m1"):
		rope_handle.global_position = get_global_mouse_position()
		whipped = true
	
	velocity = input_direction * move_speed
	
	move_and_slide()
