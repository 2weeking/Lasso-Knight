extends CharacterBody2D
@export var walk_speed = 50
@export var run_speed = 170
@export var damage : int = 1

@onready var player = get_parent().get_node("Knight")
@onready var timer = $Timer

var current_speed = 50
var make_charge = true
var direction = Vector2(0, 0)
func _ready():
	timer.timeout.connect(_timeout)

func _physics_process(delta):
	if(timer.is_stopped()):
		current_speed = walk_speed
		timer.start(7)
	
	
	if is_instance_valid(player):
		#position = position.lerp(player.position, speed * delta)
		if(current_speed==walk_speed):
			direction = (player.position - position).normalized()
		velocity = direction * current_speed
	
	move_and_collide(velocity * delta)
	
func _timeout():
	if(make_charge):
		current_speed = run_speed
		make_charge = false
		timer.start(2)	
	else:
		make_charge = true
	
