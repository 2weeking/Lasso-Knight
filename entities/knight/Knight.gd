extends KinematicBody2D

signal hp_changed(old_value, new_value)

var hp : int = 3 setget hp_set

func hp_set(new_hp: int):
	if new_hp <= 0:
			die()
	elif new_hp < hp:
		hurt_animation_player.play("hurt")
	emit_signal("hp_changed", hp, new_hp)
	hp = new_hp

# Player parameters
export var move_speed : float = 150.0
export var lasso_speed : float = 2
export var lasso_range: float = 250.0
export var lasso_goldilocks: float = 0.5	# Green bar range percentage from 0.0 - 1.0

# Sprite and animations
onready var sprite = $Sprite
onready var sense_range = $SenseRange
onready var animation_tree = $AnimationTree
onready var state_machine = animation_tree.get("parameters/playback")
onready var hurt_animation_player = $HurtAnimationPlayer

# Lasso related
onready var verlet_rope = preload("res://entities/lasso/Rope.tscn")
onready var lasso_bar = $LassoBar
onready var lasso_path = $Path2D

# Lasso golidlocks range on lassobar
var lasso_bar_bound_lower = (lasso_range/2)-(lasso_range*lasso_goldilocks/2)
var lasso_bar_bound_upper = (lasso_range/2)+(lasso_range*lasso_goldilocks/2)

var ropes = []
var velocity := Vector2.ZERO
var desired_velocity := Vector2.ZERO
var input_direction := Vector2.ZERO
var knockback := Vector2.ZERO
var roped = false
export var whipping = false

func die():
	queue_free()

func _ready():
	# Setup HP settergetter
	self.hp = self.hp
	
	# Setup lasso bar
	lasso_bar.max_value = lasso_range
	
	# LassoBar Gradient dependent on lasso range and goldilocks
	var gradient_texture = GradientTexture.new()
	var gradient = Gradient.new()
	
	gradient.set_color(0, Color.red) # bottom
	gradient.set_color(1, Color.red) # top
	gradient.add_point(lasso_bar_bound_lower/lasso_range, Color.yellow) # q1
	gradient.add_point(0.5, Color.green) # middle
	gradient.add_point(lasso_bar_bound_upper/lasso_range, Color.yellow) # q3
	
	gradient_texture.gradient = gradient
	lasso_bar.texture_under = gradient_texture

func _process(_delta):
	# Movement
	input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

func _physics_process(_delta):
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
		var enemy = rope.target as KinematicBody2D
		var timer = rope.capture_timer as Timer
		
		var dist = position.distance_to(enemy.position)
		
		#var b = (enemy.global_position.direction_to(global_position)).normalized()
		#if acos(enemy.desired_velocity.dot((enemy.global_position.direction_to(global_position)).normalized())) > deg_to_rad(60):
		#	print("ENEMY DRAGS PLAYER.")
		
		var cone_of_sight = acos(enemy.desired_velocity.dot((enemy.global_position.direction_to(global_position)).normalized()))
		
		# Counteract own velocity with enemy velocity to stimulate rope tensiond
		if enemy.is_in_group("capturing") and dist > lasso_range * 0.25 and cone_of_sight > deg2rad(120):
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
		if timer.get_time_left() == 0 and enemy.is_in_group("capturing"):
			enemy.remove_from_group("capturing")
			enemy.add_to_group("captured")
			enemy.modulate = Color.green
			lasso_bar.visible = false
		# If player is outside lasso range, break rope and reset enemy state
		elif dist > lasso_range:
			enemy.remove_from_group("capturing")
			# Queue free rope attached to enemy
			rope.queue_free()
			ropes.erase(rope)
			roped = false
			lasso_bar.visible = false
	
	velocity += knockback
	
	velocity = move_and_slide(velocity)
	knockback = lerp(knockback, Vector2.ZERO, 0.1)

func add_rope(body: KinematicBody2D):
	# Attach rope to enemy
	var rope = verlet_rope.instance()
	add_child(rope)
	rope.target = body
	ropes.append(rope)
	
	# Attach capturing timer to enemy
	var timer = Timer.new()
	rope.capture_timer = timer
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = body.capture_time
	timer.one_shot = true
	timer.autostart = true
	rope.add_child(timer)
	
	body.add_to_group("capturing")

func remove_rope(body: KinematicBody2D, kill: bool):
	# First delete rope associated with body
	for rope in ropes:
		if body == rope.target:
			rope.queue_free()
			ropes.erase(rope)
			roped = false
	
	# Optionally delete body attached
	if kill:
		body.queue_free()

func _on_Hitbox_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("enemy"):
		if body.is_in_group("captured"):
			remove_rope(body, true)
		else:
			# Deal damage
			self.hp -= body.damage
			
			# Deal knockback
			var knock_direction = body.global_position.direction_to(global_position)
			knockback = knock_direction * body.knockback_strength

func _on_LassoHurtBox_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("enemy") and not body.is_in_group("capturing") and not body.is_in_group("captured") and "alarmed" in body:
		if ropes.empty() and not roped:
			roped = true
			call_deferred("add_rope", body)
