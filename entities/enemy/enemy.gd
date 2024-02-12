extends CharacterBody2D

#much of movement in charger and other enemies is same as here, but with ability code added on.


@export var speed := 100
@export var speed_offset := 10
@export var damage := 1
@export var capture_time := 3
@export var knockback_strength := 600.0
@export var steering_force = 20 #used to make turning more smooth and flowing

@onready var player = get_parent().get_node("Knight")
@onready var sprite = $AnimatedSprite2D

var predict_length = 5 #enemy predicts where player will be this length of frames ahead (5 is temporary number
var alarmed = false #enemy has state of rest

var player_predicted_position := Vector2.ZERO #position calculated through predict length
var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var counter_direction := Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(player):
		direction = (player.position - position).normalized()
		if is_in_group("capturing"):
			desired_velocity = counter_direction * speed
			velocity = (desired_velocity - player.desired_velocity)
		elif alarmed:
			if is_in_group("captured"):
				speed += 10
			
			desired_velocity = (player_predicted_position - position).normalized() * speed
			predict_length = global_position.distance_to(player.global_position)/10
			player_predicted_position = player.position + player.velocity*delta*predict_length
			var steering = (desired_velocity - velocity).normalized()*steering_force
			desired_velocity += steering
		
		velocity = desired_velocity
		
		if velocity.x < -speed/2:
			sprite.flip_h = true
		elif velocity.x > speed/2:
			sprite.flip_h = false
		
		move_and_slide()

func _on_hitbox_area_entered(area):
	if area.name == "LassoHurtbox":
		counter_direction = direction * -1
	if area.name == "Hitbox" and not is_in_group("captured"):
		var body = area.get_parent()
		
		# Deal damage
		body.hp -= damage
		
		# Deal knockback
		var knock_direction = global_position.direction_to(body.global_position)
		body.knockback = knock_direction * knockback_strength
