extends CharacterBody2D

#much of movement in charger and other enemies is same as here, but with ability code added on.


@export var speed = 100
@export var damage : int = 1
@export var steering_force = 20 #used to make turning more smooth and flowing
@onready var player = get_parent().get_node("Knight")

var predict_length = 5 #enemy predicts where player will be this length of frames ahead (5 is temporary number
var alarmed = false #enemy has state of rest
var player_predicted_position #position calculated through predict length

func _physics_process(delta):
	if is_instance_valid(player) and alarmed:
		predict_length = global_position.distance_to(player.global_position)/10
		player_predicted_position = player.position + player.velocity*delta*predict_length
		var desired_velocity = (player_predicted_position - position).normalized()*speed
		var steering = (desired_velocity - velocity).normalized()*steering_force
		velocity = velocity + steering
		
		move_and_collide(velocity * delta)
	
func _on_alarmed():
	var direction = (player.position - position).normalized()
	velocity = direction*speed
	alarmed = true
