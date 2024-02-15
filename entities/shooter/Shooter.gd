extends KinematicBody2D

export var speed := 100
export var damage := 1
export var max_distance := 200
export var min_distance := 100
export var capture_time := 3
export var knockback_strength := 600

onready var sprite = $AnimatedSprite
onready var player = get_parent().get_node_or_null("Knight")

onready var max_movement_clock = $MaxMovementClock
onready var min_movement_clock = $MinMovementClock

onready var bullet_scene = preload("res://entities/shooter/Bullet.tscn")
onready var bullet_clock = $BulletClock

onready var rng = RandomNumberGenerator.new()

var velocity := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var counter_direction = Vector2.ZERO

var alarmed := false
var can_shoot := true


func _physics_process(_delta):
	if is_instance_valid(player):
		direction = (player.position - position).normalized()
		if is_in_group("capturing"):
			desired_velocity = counter_direction * speed
			velocity = (desired_velocity - player.desired_velocity)
		elif alarmed:
			if is_in_group("captured"):
				speed += 10
				desired_velocity = position.direction_to(player.position)*speed
			else:
			
				var distance_to_player = sqrt(global_position.distance_squared_to(player.global_position))
				if(distance_to_player<min_distance):
					start_move_away()
				elif(distance_to_player>max_distance):
					desired_velocity = (player.position-position).normalized()*speed
		
		velocity = desired_velocity
		
		if velocity.x < -speed/2.0:
			sprite.flip_h = true
		elif velocity.x > speed/2.0:
			sprite.flip_h = false
		
		velocity = move_and_slide(velocity)
		
		if(can_shoot):
			var bullet = bullet_scene.instance()
			get_parent().add_child(bullet)
			
			bullet.global_position = global_position
			bullet.velocity = (player.position-position).normalized()*bullet.speed
			bullet.rotation = get_angle_to(player.global_position)
			
			can_shoot = false
			bullet_clock.start(3)

func start_move_toward():
	if(min_movement_clock.is_stopped()):
		desired_velocity = (player.position-position).normalized()*speed
		max_movement_clock.start(rng.randf_range(0.1,0.25))

func start_move_away():
	if(max_movement_clock.is_stopped()):
		desired_velocity = (position-player.position).normalized()*speed
		max_movement_clock.start(rng.randf_range(0.1,0.25))


func _on_MaxMovementClock_timeout():
	velocity = Vector2.ZERO


func _on_MinMovementClock_timeout():
	velocity = Vector2.ZERO

func _on_BulletClock_timeout():
	can_shoot = true

func _on_Hitbox_area_entered(area):
	if area.name == "LassoHurtbox":
		counter_direction = direction * -1
	elif area.name == "SenseRange":
		alarmed = true
