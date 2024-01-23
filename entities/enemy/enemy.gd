extends CharacterBody2D

@export var SPEED = 50.0
@export var player : CharacterBody2D

func _physics_process(delta):	
	if is_instance_valid(player):
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
	
	move_and_collide(velocity * delta)
