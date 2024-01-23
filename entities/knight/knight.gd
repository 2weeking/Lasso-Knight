extends CharacterBody2D

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var lasso = $Lasso

func _physics_process(_delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("m1"):
		lasso.look_at(get_global_mouse_position())
	
	# Absorb Captured Enemies
	var collision = get_last_slide_collision()
	if collision is KinematicCollision2D and is_instance_valid(collision) and not collision.is_queued_for_deletion():
		if collision.get_collider():
			var body = collision.get_collider()
			if body.is_in_group("enemies") and body.is_in_group("captured"):
				# Delete rope corresponding to collided enemy
				pass
				"""
				var children = body.get_children()
				for child in children:
					if child is RopeHandle:
						get_node(child.rope_path).queue_free()
				body.queue_free()
				"""
	
	velocity = input_direction * move_speed
	
	move_and_slide()

func reel_in(_body):
	# Instance new rope on knight
	# Instance new rope handle at body)
	# Connect rope from knight to body
	# delete body at end
	pass

func _on_lasso_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)
