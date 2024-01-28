extends Node2D

@onready var origin: CharacterBody2D
@export var target: CharacterBody2D

@export var range: float = 250
@export var ropeLength: float = 30
@export var constrain: float = 1	# distance between points
@export var gravity: Vector2 = Vector2(0,9.8)
@export var dampening: float = 0.9
@export var startPin: bool = true
@export var endPin: bool = true

@onready var line2D: = $Line2D
@onready var progressBar = $ProgressBar

var pos: PackedVector2Array
var posPrev: PackedVector2Array
var pointCount: int

func _ready()->void:
	progressBar.max_value = range
	pointCount = get_pointCount(ropeLength)
	resize_arrays()
	init_position()

func get_pointCount(distance: float)->int:
	return int(ceil(distance / constrain))

func resize_arrays():
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position()->void:
	for i in range(pointCount):
		pos[i] = position + Vector2(constrain *i, 0)
		posPrev[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO

"""
func _unhandled_input(event:InputEvent)->void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("click"):	#Move start point
			set_start(get_global_mouse_position())
		if Input.is_action_pressed("right_click"):	#Move start point
			set_last(get_global_mouse_position())
	elif event is InputEventMouseButton && event.is_pressed():
		if event.button_index == 1:
			set_start(get_global_mouse_position())
		elif event.button_index == 2:
			set_last(get_global_mouse_position())
"""

func _process(delta)->void:
	# Lock rope and bodies to certain range of distance
	if target and origin:
		var dist = origin.position.distance_to(target.position)
		progressBar.global_position = origin.global_position
		progressBar.value = dist
		if dist < range:
			set_start(origin.position)
			set_last(target.position)
		else:
			print("ROPE BROKE")
			target.remove_from_group("capturing")
			queue_free()
	update_points(delta)
	update_constrain()
	
	#update_constrain()	#Repeat to get tighter rope
	#update_constrain()
	
	# Send positions to Line2D for drawing
	line2D.points = pos

func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func set_last(p:Vector2)->void:
	pos[pointCount-1] = p
	posPrev[pointCount-1] = p

func update_points(delta)->void:
	for i in range (pointCount):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=pointCount-1) || (i==0 && !startPin) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		# if first point
		if i == 0:
			if startPin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == pointCount-1:
			pass
		# all the rest
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
