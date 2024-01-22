extends CharacterBody2D

const SPEED = 100.0

@export var player : CharacterBody2D

func _physics_process(_delta):
	if player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
	move_and_slide()
