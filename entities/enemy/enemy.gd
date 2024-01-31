extends CharacterBody2D

@export var speed = 50
@export var damage : int = 1
@export var moving: bool = true

@onready var player = get_parent().get_node("Knight")

var desired_velocity = Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(player) and moving:
		var direction = (player.position - position).normalized()
		desired_velocity = direction * speed
		if is_in_group("capturing"):
			direction *= -1
			velocity.x = desired_velocity.x - player.desired_velocity.x
		else:
			# Speed up towards player to simulate reel in effect
			if is_in_group("captured"):
				speed += 5
			velocity = desired_velocity
	
	move_and_slide()


func _on_hitbox_area_entered(area):
	pass
