extends CharacterBody2D

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var lasso = $Lasso

var captured_enemies = {}

func _physics_process(_delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("m1"):
		lasso.look_at(get_global_mouse_position())
	
	# Captured enemies in dictionary {body: rope} pair
	for body in captured_enemies:
		var rope = captured_enemies[body]
		rope.set_point_position(1, to_local(body.position))
	
	# Absorb Captured Enemies
	var collision = get_last_slide_collision()
	if collision is KinematicCollision2D and is_instance_valid(collision) and not collision.is_queued_for_deletion():
		if collision.get_collider():
			var body = collision.get_collider()
			if body.is_in_group("enemies") and body.is_in_group("captured"):
				# Delete rope
				captured_enemies[body].queue_free()
				# Remove enemy and rope from captured enemy dictionary
				captured_enemies.erase(body)
				# Delete enemy attached
				body.queue_free()
	
	velocity = input_direction * move_speed
	
	move_and_slide()

func reel_in(body):
	# Instance new rope on knight
	var rope = Line2D.new()
	rope.width = 2
	rope.default_color = Color(0.588, 0.447, 0.349)
	add_child(rope)
	# Add rope point on knight and enemy and connect (relative position to knight)
	rope.add_point(Vector2.ZERO)
	rope.add_point(to_local(body.position))
	# Save captured enemies in array to continiously update in process function
	captured_enemies[body] = rope

func _on_lasso_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)
