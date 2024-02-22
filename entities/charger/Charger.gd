extends KinematicBody2D
export var walk_speed := 50
export var run_speed := 300
export var damage := 1
export var knockback_strength := 800
export var capture_time = 7

onready var player = get_parent().get_node("Knight")
onready var sprite = $AnimatedSprite
onready var timer = $Timer

var predict_length=walk_speed/10.0
var player_predicted_position
var alarmed = false
var current_speed = 50
var make_charge = true

var velocity := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var steering_force := 20
var steering := Vector2.ZERO
var counter_direction = Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(player):
		predict_length = global_position.distance_to(player.global_position)/10
		player_predicted_position = player.position + player.velocity*delta*predict_length
		direction = (player_predicted_position - position).normalized()
		
		if is_in_group("captured"):
			desired_velocity = direction * run_speed
		elif alarmed:
			if is_in_group("capturing"):
					direction = counter_direction
			
			if timer.is_stopped():
				current_speed = walk_speed
				timer.start(7)
			
			if(current_speed==walk_speed):
				desired_velocity = direction * walk_speed
				steering = (desired_velocity - velocity).normalized()*steering_force
				desired_velocity += steering
			if(current_speed==run_speed):
				desired_velocity = direction*run_speed
	
	velocity = desired_velocity
	
	if velocity.x < -walk_speed/2.0:
		sprite.flip_h = true
	elif velocity.x > walk_speed/2.0:
		sprite.flip_h = false
	
	velocity = move_and_slide(velocity)
	
func _on_Timer_timeout():
	if make_charge and not is_in_group("capturing"):
		set_modulate(Color.red)
		current_speed = run_speed
		make_charge = false
		timer.start(1)	
		direction = velocity.normalized()
	else:
		if not is_in_group("captured"):
			set_modulate(Color.white)
		make_charge = true

func _on_Hitbox_area_entered(area):
	if area.name == "LassoHurtbox":
		counter_direction = (player.position - position).normalized() * -1
	elif area.name == "SenseRange":
		alarmed = true


func _on_Hurtbox_area_entered(area):
	if area.name == "Hitbox" and area.get_parent().is_in_group("player"):
		current_speed = walk_speed
