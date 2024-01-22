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
	
	# Absorb Captured Enemies
	var collision = get_last_slide_collision()
	if collision is KinematicCollision2D and is_instance_valid(collision) and not collision.is_queued_for_deletion():
		if collision.get_collider():
			var body = collision.get_collider()
			if body.is_in_group("enemies") and body.is_in_group("captured"):
				# Delete rope corresponding to collided enemy
				var children = body.get_children()
				for child in children:
					if child is RopeHandle:
						get_node(child.rope_path).queue_free()
				body.queue_free()
	
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
	# delete body at end
	if is_in_group("captured"):
		body.SPEED = 200.0

func _on_lasso_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)
