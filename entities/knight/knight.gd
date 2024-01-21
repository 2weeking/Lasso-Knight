extends CharacterBody2D

@export var move_speed : float = 150.0
@export var lasso_speed : float = 1.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var rope = $Rope
@onready var rope_handle = $RopeHandle
@onready var lasso = $Lasso
@onready var lasso_path = $Lasso/Path2D/PathFollow2D

var lassoed = false

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if Input.is_action_just_pressed("m1") and not lassoed:
		lasso.look_at(get_global_mouse_position())
		lassoed = true
	
	if lassoed:
		lasso_path.progress_ratio += lasso_speed * delta
		if lasso_path.progress_ratio == 1:
			lasso_path.progress_ratio = 0
			lassoed = false
	
	velocity = input_direction * move_speed
	
	move_and_slide()
