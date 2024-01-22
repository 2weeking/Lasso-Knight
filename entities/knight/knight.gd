extends CharacterBody2D

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var lasso = $Lasso
@onready var lasso_rope = $Lasso/Rope
@onready var lasso_path = $Lasso/Path2D/PathFollow2D

var lassoed = false

func _physics_process(delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
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

func reel_in(body):
	# Instance new rope on knight
	var captured_lasso = Rope.new()
	captured_lasso.rope_length = 130
	captured_lasso.gravity = 50
	captured_lasso.color = Color(0.557, 0.302, 0.118)
	add_child(captured_lasso)
	# Instance new rope handle at body
	var captured_lasso_handle = RopeHandle.new()
	body.add_child(captured_lasso_handle)
	# Connect rope from knight to body
	captured_lasso_handle.set_rope_path(captured_lasso.get_path())
	# slowly reel in overtime towards knight
	
	# delete body at end

func _on_lasso_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)
