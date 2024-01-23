extends CharacterBody2D

@export var SPEED = 10.0
@export var player : CharacterBody2D

func _physics_process(_delta):	
	if is_instance_valid(player):
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
	
	move_and_slide()
