extends CharacterBody2D

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2.0

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var lasso = $Lasso

# key: value pair
# {body: rope}
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
		#rope.set_point_position(1, to_local(body.position))
		rope.points = lasso_to_curve(Vector2.ZERO, to_local(body.position))
	
	# Absorb Captured Enemies
	var collision = get_last_slide_collision()
	if collision is KinematicCollision2D and is_instance_valid(collision) and not collision.is_queued_for_deletion():
		if collision.get_collider():
			var body = collision.get_collider()
			if body.is_in_group("enemies") and body.is_in_group("captured"):
				# Delete rope and enemy attached
				captured_enemies[body].queue_free()
				body.queue_free()
				# Remove enemy and rope entries from captured_enemy dictionary
				captured_enemies.erase(body)
	
	velocity = input_direction * move_speed
	
	move_and_slide()

func lasso_to_curve(p0_vertex: Vector2, p1_vertex: Vector2):
	var curve = Curve2D.new()
	# Adjust curves to change sides
	var p0_out = Vector2.ZERO
	if p0_vertex.x > p1_vertex.x:
		p0_out = Vector2(-50, 0)
	else:
		p0_out = Vector2(50, 0)
	curve.add_point(p0_vertex, Vector2.ZERO, p0_out);
	curve.add_point(p1_vertex, Vector2.ZERO, Vector2.ZERO);
	return curve.get_baked_points()

func reel_in(body):
	# Instance new rope on knight
	var rope = Line2D.new()
	rope.width = 2
	rope.default_color = Color(0.588, 0.447, 0.349)
	add_child(rope)
	# Add rope point on knight and enemy and connect (relative position to knight)
	rope.points = lasso_to_curve(Vector2.ZERO, to_local(body.position))
	#rope.add_point(Vector2.ZERO)
	#rope.add_point(to_local(body.position))
	# Save captured enemies in array to continiously update in process function
	captured_enemies[body] = rope

func _on_lasso_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)