extends CharacterBody2D

@export var speed := 50
@export var speed_offset := 10
@export var damage := 1
@export var moving := true
@export var capture_time := 3
@export var knockback_strength := 600.0

@onready var player = get_parent().get_node("Knight")
@onready var sprite = $AnimatedSprite2D

var desired_velocity := Vector2.ZERO
var direction := Vector2.ZERO
var counter_direction := Vector2.ZERO
var knockback := Vector2.ZERO

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
	
	velocity += knockback
	move_and_slide()
	knockback = knockback.lerp(Vector2.ZERO, 0.1)


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
		# Also apply knockback to self
		var opposite_direction = body.global_position.direction_to(global_position)
		knockback = opposite_direction * knockback_strength
