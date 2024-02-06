extends CharacterBody2D

@export var speed = 50
@export var speed_offset = 10
@export var damage : int = 1
@export var moving : bool = true
@export var capture_time : int = 3

@onready var player = get_parent().get_node("Knight")
@onready var sprite = $AnimatedSprite2D

var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var counter_direction := Vector2.ZERO

func _physics_process(_delta):
	if is_instance_valid(player) and moving:
		direction = (player.position - position).normalized()
		if is_in_group("capturing"):
			desired_velocity = counter_direction * speed
			velocity = (desired_velocity - player.desired_velocity) * speed_offset
		else:
			# Speed up towards player to simulate reel in effect
			if is_in_group("captured"):
				speed += 5
			desired_velocity = direction * speed
	
	velocity = desired_velocity
	
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	
	move_and_slide()


func _on_hitbox_area_entered(area):
	if area.name == "LassoHurtBox":
		counter_direction = direction * -1
