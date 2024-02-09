extends CharacterBody2D

signal hp_changed(old_value: int, new_value: int)

@export var hp : int = 3 :
	get:
		return hp
	set(new_hp):
		if new_hp <= 0:
			die()
		hp_changed.emit(hp, new_hp)
		hp = new_hp

# Player parameters
@export var move_speed : float = 150.0
@export var lasso_speed : float = 2
@export var lasso_range: float = 250.0
@export var lasso_goldilocks: float = 0.5	# Green bar range percentage from 0.0 - 1.0

# Sprite and animationms
@onready var sprite = $Sprite2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

# Lasso related
@onready var verlet_rope = preload("res://entities/lasso/verlet_rope.tscn")
@onready var lasso_bar = $LassoBar
@onready var lasso_path = $Path2D

# Lasso golidlocks range on lassobar
var lasso_bar_bound_lower = (lasso_range/2)-(lasso_range*lasso_goldilocks/2)
var lasso_bar_bound_upper = (lasso_range/2)+(lasso_range*lasso_goldilocks/2)

var ropes = []
var whipping = false
var desired_velocity = Vector2.ZERO

func die():
	queue_free()

func _ready():
	# Setup HP settergetter
	hp = hp
	
	# Setup lasso bar
	lasso_bar.max_value = lasso_range
	
	# LassoBar Gradient dependent on lasso range and goldilocks
	var gradient_texture = GradientTexture1D.new()
	var gradient = Gradient.new()
	
	gradient.set_color(0, Color.CRIMSON) # bottom
	gradient.set_color(1, Color.CRIMSON) # top
	gradient.add_point(lasso_bar_bound_lower/lasso_range, Color.YELLOW) # q1
	gradient.add_point(0.5, Color.GREEN) # middle
	gradient.add_point(lasso_bar_bound_upper/lasso_range, Color.YELLOW) # q3
	
	gradient_texture.gradient = gradient
	lasso_bar.texture_under = gradient_texture

func _physics_process(_delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Animation and sprite related stuff
	if input_direction != Vector2.ZERO:
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
	# Flip sprite depending on direction
	if input_direction.x > 0:
		sprite.flip_h = false
	elif input_direction.x < 0:
		sprite.flip_h = true
	
	# Lasso
	if Input.is_action_just_pressed("whip") and not whipping:
		lasso_path.look_at(get_global_mouse_position())
		state_machine.travel("whip")
	
	# Desired_velocity to used to counteract movement during rope capturing
	desired_velocity = input_direction * move_speed
	
	velocity = desired_velocity
	
	# Deal with ropes children to knight and captured enemies attached
	for rope in ropes:
		var enemy = rope.target as CharacterBody2D
		var timer = rope.capture_timer as Timer
		
		var dist = position.distance_to(enemy.position)
		
		# Counteract own velocity with enemy velocity to stimulate rope tensiond
		if enemy.is_in_group("capturing"):
			velocity += enemy.desired_velocity
		
		# Adjust progress bar and convert dist to bar offset
		lasso_bar.visible = true
		lasso_bar.texture_progress_offset.x = -(dist/lasso_range*50)
		# If in range, resume capture timer
		if dist > lasso_bar_bound_lower and dist < lasso_bar_bound_upper:
			timer.paused = false
		else:
			timer.paused = true
		
		# If timer is done, finish capturing enemy
		if timer.get_time_left() == 0:
			enemy.remove_from_group("capturing")
			enemy.add_to_group("captured")
			enemy.modulate = Color.GREEN
			lasso_bar.visible = false
		# If player is outside lasso range, break rope and reset enemy state
		elif dist > lasso_range:
			enemy.remove_from_group("capturing")
			# Queue free rope attached to enemy
			rope.queue_free()
			ropes.erase(rope)
			lasso_bar.visible = false
	
	move_and_slide()

func add_rope(body: CharacterBody2D):
	# Attach rope to enemy
	var rope = verlet_rope.instantiate()
	rope.target = body
	add_child(rope)
	ropes.append(rope)
	
	# Attach capturing timer to enemy
	var timer = Timer.new()
	rope.capture_timer = timer
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = body.capture_time
	timer.one_shot = true
	timer.autostart = true
	rope.add_child(timer)
	
	body.add_to_group("capturing")

func remove_rope(body: CharacterBody2D, kill: bool):
	# First delete rope associated with body
	for rope in ropes:
		if body == rope.target:
			rope.queue_free()
			ropes.erase(rope)
	
	# Optionally delete body attached
	if kill:
		body.queue_free()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy"):
		if body.is_in_group("captured"):
			remove_rope(body, true)
		elif body.is_in_group("capturing"):
			pass
		else:
			hp -= body.damage

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("capturing") and not body.is_in_group("captured"):
		call_deferred("add_rope", body)
