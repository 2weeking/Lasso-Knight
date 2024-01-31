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

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2
@export var lasso_range: float = 250.0
@export var lasso_goldilocks: float = 0.25

@onready var verlet_rope = preload("res://entities/lasso/verlet_rope.tscn")
@onready var lasso_pathfollow = $HurtBox/Path2D/PathFollow2D
@onready var lasso_bar = $LassoBar
@onready var hurtbox = $HurtBox

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var ropes = []
var desired_velocity = Vector2.ZERO

func die():
	queue_free()

func _ready():
	hp = hp
	lasso_bar.visible = false
	lasso_bar.max_value = lasso_range

var whipping = false

func _physics_process(delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("whip") and not whipping:
		hurtbox.look_at(get_global_mouse_position())
		hurtbox.set_collision_mask_value(3, true)
		lasso_pathfollow.progress_ratio = 0
		whipping = true
	
	if whipping:
		lasso_pathfollow.progress_ratio += lasso_speed * delta
		if lasso_pathfollow.progress_ratio >= 0.95:
			hurtbox.set_collision_mask_value(3, false)
			whipping = false
	
	desired_velocity = input_direction * move_speed
	
	velocity = desired_velocity
	
	# Deal with ropes children to knight and captured enemies attached
	for rope in ropes:
		lasso_bar.visible = true
		var enemy = rope.target
		var timer = rope.capture_timer
		
		velocity -= enemy.desired_velocity
		# Lock rope and bodies to certain range of distance
		var dist = position.distance_to(enemy.position)
		#lasso_bar.value = dist
		lasso_bar.texture_progress_offset.x = -(dist/lasso_range*50)
		# If in range 
		if dist > (lasso_range/2)-(lasso_range*lasso_goldilocks/2) and dist < (lasso_range/2)+(lasso_range*lasso_goldilocks/2):
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
			#lasso_bar.value = 0
			enemy.remove_from_group("capturing")
			# Queue free rope attached to enemy
			rope.queue_free()
			ropes.erase(rope)
			lasso_bar.visible = false
	
	move_and_slide()

func add_new_rope(body):
	var rope = verlet_rope.instantiate()
	rope.target = body
	add_child(rope)
	ropes.append(rope)
	
	var timer = Timer.new()
	rope.capture_timer = timer
	timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = 3
	timer.one_shot = true
	timer.autostart = true
	rope.add_child(timer)
	body.add_to_group("capturing")

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy"):
		if body.is_in_group("captured"):
			for rope in ropes:
				if body == rope.target:
					rope.queue_free()
					ropes.erase(rope)
			body.queue_free()
		else:
			hp -= body.damage

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("capturing") and not body.is_in_group("captured"):
		call_deferred("add_new_rope", body)
