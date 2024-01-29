extends CharacterBody2D
var alarmed = false
@export var speed = 50
@export var damage : int = 1
@export var steering_force = 10

@onready var player = get_parent().get_node("Knight")

func _physics_process(delta):
	if is_instance_valid(player) and alarmed:
		var desired_velocity = (player.position - position).normalized()*speed
		var steering = (desired_velocity - velocity).normalized()*steering_force
		velocity = velocity + steering
		
		move_and_collide(velocity * delta)
	
func _on_alarmed():
	var direction = (player.position - position).normalized()
	velocity = direction*speed
	alarmed = true
