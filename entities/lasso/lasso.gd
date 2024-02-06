extends Area2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer

@export var reel_rate : float = 7.0
@export var lasso_curve : float = 50.0
@export var lasso_width : float = 2.0
@export var lasso_color : Color = Color(0.588, 0.447, 0.349)

# key: value pair
# {body: rope}
var captured_enemies = {}

func _physics_process(delta):
	# Captured enemies in dictionary {body: rope} pair
	for body in captured_enemies:
		var rope = captured_enemies[body]
		rope.points = lasso_to_curve(Vector2.ZERO, to_local(body.position))
		# Slowly increase reeling speed
		if Input.is_action_pressed("reel_in"):
			body.speed += reel_rate

func whip(mouse_pos):
	look_at(mouse_pos)
	animation_player.play("whip")

func lasso_to_curve(p0_vertex: Vector2, p1_vertex: Vector2):
	var curve = Curve2D.new()
	# Adjust curves to change sides
	var p0_out = Vector2.ZERO
	if p0_vertex.x > p1_vertex.x:
		p0_out = Vector2(-lasso_curve, 0)
	else:
		p0_out = Vector2(lasso_curve, 0)
	curve.add_point(p0_vertex, Vector2.ZERO, p0_out);
	curve.add_point(p1_vertex, Vector2.ZERO, Vector2.ZERO);
	return curve.get_baked_points()

func reel_in(body):
	# Instance new rope on knight
	var rope = Line2D.new()
	rope.width = lasso_width
	rope.default_color = lasso_color
	add_child(rope)
	# Add rope point on knight and enemy and connect (relative position to knight)
	rope.points = lasso_to_curve(Vector2.ZERO, to_local(body.position))
	# Save captured enemies in array to continiously update in process function
	captured_enemies[body] = rope

func _on_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		body.add_to_group("captured")
		reel_in(body)