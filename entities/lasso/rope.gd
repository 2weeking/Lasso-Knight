extends Node2D

var RopePiece = preload("res://entities/lasso/rope_piece.tscn")
var piece_length := 12.0
var rope_parts := []
var rope_close_tolerance := 4.0
var rope_points: PackedVector2Array = []

#@export var rope_start_piece_path: NodePath
#@export var rope_end_piece_path: NodePath
@export var rope_gravity: float = 1
@export var rope_linear_damp: float = 1
@export var rope_angular_damp = 1
@export var joint_softness: float = 0.1 
@export var joint_bias: float = 0.1

@export var rope_start_piece: RigidBody2D
@export var rope_end_piece: RigidBody2D
@onready var rope_start_joint = rope_start_piece.get_node("CollisionShape2D/PinJoint2D")
@onready var rope_end_joint = rope_end_piece.get_node("CollisionShape2D/PinJoint2D")

func spawn_rope():
	# Setup rope start and end pieces position
	#rope_start_piece.global_position = start_pos
	#rope_end_piece.global_position = end_pos
	
	# Get position of joints
	var start_pos = rope_start_joint.global_position
	var end_pos = rope_end_joint.global_position
	
	# Calculate amount of pieces to generate between start and end points
	var distance = start_pos.distance_to(end_pos)
	var pieces_amount = round(distance / piece_length)
	# Angle between points
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	
	create_rope(pieces_amount, rope_start_piece, end_pos, spawn_angle)

func create_rope(pieces_amount: int, parent: Object, end_pos: Vector2, spawn_angle: float):
	# Start chaining pieces from start piece as parent
	for i in pieces_amount:
		# Assign parent as new piece
		parent = add_piece(parent, i, spawn_angle)
		parent.set_name("rope_piece_"+str(i))
		rope_parts.append(parent)
		
		# Get current joint, exclusing joint end pieces
		var parent_joint = parent.get_node("CollisionShape2D/PinJoint2D")
		# Setting current joint parameters
		parent_joint.softness = joint_softness
		parent_joint.bias = joint_bias
		# Stop chaining when approaching rope end piece
		if parent_joint.global_position.distance_to(end_pos) < rope_close_tolerance:
			break
	
	rope_end_joint.node_a = rope_end_piece.get_path()
	rope_end_joint.node_b = rope_parts[-1].get_path()

func add_piece(parent: Object, id: int, spawn_angle: float) -> Object:
	# Get joint info on current parent
	var joint : PinJoint2D = parent.get_node("CollisionShape2D/PinJoint2D") as PinJoint2D
	# Generate new rope piece
	var piece : Object = RopePiece.instantiate() as Object
	# Set position and rotation of new piece equal to parent joint
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	# Set new piece parent as current piece
	piece.parent = self
	piece.id = id
	# Setting rope piece parameters
	piece.gravity_scale = rope_gravity
	piece.linear_damp = rope_linear_damp
	piece.angular_damp = rope_angular_damp
	
	add_child(piece)
	
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	
	return piece

func get_rope_points():
	rope_points.clear()
	
	rope_points.append(rope_start_joint.global_position)
	for r in rope_parts:
		rope_points.append(r.global_position)
	rope_points.append(rope_end_joint.global_position)

func _process(_delta):
	queue_redraw()

func _draw():
	get_rope_points()
	draw_polyline(rope_points, Color.SADDLE_BROWN, 1)
