extends KinematicBody2D

#much of movement in charger and other enemies is same as here, but with ability code added on.
export var speed := 100
export var speed_offset := 10
export var damage := 1
export var capture_time := 3
export var knockback_strength := 600.0
export var steering_force = 20 #used to make turning more smooth and flowing

onready var player = get_tree().current_scene.get_node("Knight")
onready var sprite = $AnimatedSprite

var predict_length = 5 #enemy predicts where player will be this length of frames ahead (5 is temporary number
var alarmed = false #enemy has state of rest

var velocity := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var player_predicted_position := Vector2.ZERO #position calculated through predict length
var direction := Vector2.ZERO
var counter_direction := Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(player):
		direction = (player.position - position).normalized()
		if is_in_group("capturing"):
			desired_velocity = (counter_direction * speed)
		elif alarmed:
			if is_in_group("captured"):
				speed += 10
			
			desired_velocity = (player_predicted_position - position).normalized() * speed
			predict_length = global_position.distance_to(player.global_position)/10
			player_predicted_position = player.position + player.velocity*delta*predict_length
			var steering = (desired_velocity - velocity).normalized()*steering_force
			desired_velocity += steering
		
		velocity = desired_velocity
		
		if velocity.x < -speed/2.0:
			sprite.flip_h = true
		elif velocity.x > speed/2.0:
			sprite.flip_h = false
		
		if velocity != Vector2.ZERO:
			sprite.play("walk")
		else:
			sprite.play("idle")
		
		velocity = move_and_slide(velocity)

func _on_Hitbox_area_entered(area):
	if area.name == "LassoHurtbox":
		counter_direction = direction * -1
	elif area.name == "SenseRange":
		alarmed = true
