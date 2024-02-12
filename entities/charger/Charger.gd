extends CharacterBody2D
@export var walk_speed := 50
@export var run_speed := 300
@export var damage := 1
@export var knockback_strength := 800
@export var capture_time = 7

@onready var player = get_parent().get_node("Knight")
@onready var sprite = $Sprite2D
@onready var timer = $Timer

var predict_length=walk_speed/10
var player_predicted_position
var alarmed = false
var current_speed = 50
var make_charge = true
var direction := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var steering_force := 20
var steering := Vector2.ZERO
var counter_direction = Vector2.ZERO

func _physics_process(delta):
	if is_instance_valid(player):
		if is_in_group("capturing"):
			desired_velocity = counter_direction * walk_speed
			velocity = (desired_velocity - player.desired_velocity)
		elif alarmed:
			if timer.is_stopped():
				current_speed = walk_speed
				timer.start(7)
			
			if(current_speed==walk_speed):
				predict_length = global_position.distance_to(player.global_position)/10
				player_predicted_position = player.position + player.velocity*delta*predict_length
				desired_velocity = (player_predicted_position - position).normalized()*walk_speed
				var steering = (desired_velocity - velocity).normalized()*steering_force
				desired_velocity += steering
			if(current_speed==run_speed):
				desired_velocity = direction*run_speed
	
	velocity = desired_velocity
	
	if velocity.x < -walk_speed/2:
		sprite.flip_h = true
	elif velocity.x > walk_speed/2:
		sprite.flip_h = false
	
	move_and_slide()
	
func _on_timer_timeout():
	if(make_charge):
		set_modulate(Color.RED)
		current_speed = run_speed
		make_charge = false
		timer.start(1)	
		direction = velocity.normalized()
	else:
		set_modulate(Color.WHITE)
		make_charge = true

func _on_hitbox_area_entered(area):
	if area.name == "LassoHurtbox":
		counter_direction = (player.position - position).normalized() * -1
	if area.name == "Hitbox" and not is_in_group("captured"):
		var body = area.get_parent()
		
		# Deal damage
		body.hp -= damage
		
		# Deal knockback
		var knock_direction = global_position.direction_to(body.global_position)
		body.knockback = knock_direction * knockback_strength
