extends CharacterBody2D

@export var speed = 50
@export var damage : int = 1
@export var moving: bool = true

@onready var player = get_parent().get_node("Knight")

func _physics_process(delta):
	if is_instance_valid(player) and moving:
		var direction = (player.position - position).normalized()
		if is_in_group("captured"):
			direction *= -1
		velocity = direction * speed
	
	move_and_slide()
