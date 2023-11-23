extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const SPEED = 300.0
const MAX_SPEED = 2000
const JUMP_VELOCITY = -400.0
const FRICTION_AIR = 0.95
const FRICTION_GROUND = 0.85
const CHAIN_PULL = 105

var chain_velocity := Vector2(0,0)
var can_jump = false

"""
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$Chain.shoot(event.position - get_viewport().size * 0.5)
		else:
			$Chain.release()
"""

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Walk
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	"""
	# Hook physics
	if $Chain.hooked:
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down weaker
			chain_velocity.y *= 0.55
		else:
			# Pulling up stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(velocity.x):
			# If walking diff direction than chain pull, reduce pull
			chain_velocity.x *= 0.7
	else:
		# No chain velocity if not hooked
		chain_velocity = Vector2(0,0)
	
	# Apply chain velocity
	velocity += chain_velocity
	"""
	move_and_slide()
	
	# Friction on ground
	if is_on_floor():
		velocity.x *= FRICTION_GROUND
		if velocity.y >= 5:velocity.y = 5
	elif is_on_ceiling() and velocity.y <= -5:
		velocity.y = -5

	# Friciton on Air
	if not is_on_floor():
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
