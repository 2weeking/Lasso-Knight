extends Node2D

export(NodePath) var target
export(NodePath) var capture_timer

export var ropeLength: float = 30
export var constrain: float = 1	# distance between points
export var gravity: Vector2 = Vector2(0,9.8)
export var dampening: float = 0.9
export var startPin: bool = true
export var endPin: bool = true

onready var line2D = $Line2D
onready var timer_label := $TimerLabel

var pos: PoolVector2Array
var posPrev: PoolVector2Array
var pointCount: int

func _ready()->void:
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

func _process(_delta):
	if capture_timer:
		#timer_label.global_position = get_parent().global_position
		timer_label.set_text(str(capture_timer.get_time_left()).pad_decimals(1))

func _physics_process(delta)->void:
	#set_start(to_local(target.global_position))
	if target is Path2D:
		set_last(to_local(target.get_curve().get_point_position(0) + target.global_position))
		#set_last(to_local(target.global_position + Vector2(-5, 10)))
	else:
		set_last(to_local(target.global_position))
	update_points(delta)
	update_constrain()
	
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
			pos[i] += velocity + ((gravity.rotated(-global_rotation)) * delta)

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
