extends CharacterBody2D

@export var speed := 100
@export var damage := 1
@export var max_distance := 200
@export var min_distance := 100
@export var capture_time := 3
@export var knockback_strength := 600

@onready var sprite = $Sprite2D
@onready var player = get_parent().get_node("Knight")

@onready var max_movement_clock = get_node("max_movement_clock")
@onready var min_movement_clock = get_node("min_movement_clock")

@onready var seed_scene = preload("res://entities/seed_shooter/seed/seed.tscn")
@onready var seed_clock = get_node("seed_clock")

@onready var rng = RandomNumberGenerator.new()

var alarmed := false
var can_shoot := true
var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var counter_direction = Vector2.ZERO

func _physics_process(_delta):
	if is_instance_valid(player):
		direction = (player.position - position).normalized()
		if is_in_group("capturing"):
			desired_velocity = counter_direction * speed
			velocity = (desired_velocity - player.desired_velocity)
		elif alarmed:
			if is_in_group("captured"):
				speed += 10
				desired_velocity = (player.position-position).normalized()*speed
			else:
				var distance_to_player = sqrt(global_position.distance_squared_to(player.global_position))
				if(distance_to_player<min_distance):
					start_move_away()
				elif(distance_to_player>max_distance):
					desired_velocity = (player.position-position).normalized()*speed
		
		velocity = desired_velocity
		
		if velocity.x < -speed/2:
			sprite.flip_h = true
		elif velocity.x > speed/2:
			sprite.flip_h = false
		
		move_and_slide()
		
		if(can_shoot):
			var seed = seed_scene.instantiate()
			get_parent().add_child(seed)
			
			seed.global_position = global_position
			seed.velocity = (player.position-position).normalized()*seed.speed
			
			can_shoot = false
			seed_clock.start(3)

func start_move_toward():
	if(min_movement_clock.is_stopped()):
		desired_velocity = (player.position-position).normalized()*speed
		max_movement_clock.start(rng.randf_range(0.1,0.25))

func start_move_away():
	if(max_movement_clock.is_stopped()):
		desired_velocity = (position-player.position).normalized()*speed
		max_movement_clock.start(rng.randf_range(0.1,0.25))


func _on_max_movement_clock_timeout():
	velocity = Vector2.ZERO


func _on_min_movement_clock_timeout():
	velocity = Vector2.ZERO


func _on_seed_clock_timeout():
	can_shoot = true


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
