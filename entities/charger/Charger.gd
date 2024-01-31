extends CharacterBody2D
@export var walk_speed = 100
@export var run_speed = 200
@export var damage : int = 1

@onready var player = get_parent().get_node("Knight")
@onready var timer = $Timer

var predict_length=walk_speed/10
var player_predicted_position
var alarmed = false
var current_speed = 50
var make_charge = true
var direction = Vector2(0, 0)
var desired_velocity
var steering_force = 20
var steering = Vector2(0,0)

func _ready():
	timer.timeout.connect(_timeout)

func _physics_process(delta):
	
	if(alarmed):
		if(timer.is_stopped()):
			current_speed = walk_speed
			timer.start(7)
		
		
		if is_instance_valid(player):
			#position = position.lerp(player.position, speed * delta)
			if(current_speed==walk_speed):
				predict_length = global_position.distance_to(player.global_position)/10
				player_predicted_position = player.position + player.velocity*delta*predict_length
				var desired_velocity = (player_predicted_position - position).normalized()*walk_speed
				var steering = (desired_velocity - velocity).normalized()*steering_force
				velocity = velocity + steering
			if(current_speed==run_speed):
				velocity = direction*run_speed
				
				
		
		move_and_collide(velocity * delta)
	
func _timeout():
	if(make_charge):
		current_speed = run_speed
		make_charge = false
		timer.start(2)	
		direction = velocity.normalized()
	else:
		make_charge = true
	
func _on_alarmed():
	var direction = (player.position - position).normalized()
	velocity = direction*walk_speed
	alarmed = true
