extends CharacterBody2D

signal hp_changed(old_value: int, new_value: int)
signal alarmed()
@export var hp : int = 3 :
	get:
		return hp
	set(new_hp):
		if new_hp <= 0:
			die()
		hp_changed.emit(hp, new_hp)
		hp = new_hp

@export var move_speed : float = 150.0
@export var lasso_speed : float = 2.0


@onready var sense_range = $SenseRange
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var lasso = $Lasso

func die():
	queue_free()

func _ready():
	hp = hp

func _physics_process(_delta):
	# Movement
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Lasso
	if Input.is_action_just_pressed("whip"):
		lasso.whip(get_global_mouse_position())
	
	velocity = input_direction * move_speed
	
	move_and_slide()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("captured"):
		hp -= body.damage

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and body.is_in_group("captured"):
		# Delete rope and enemy attached
		lasso.captured_enemies[body].queue_free()
		body.queue_free()
		# Remove enemy and rope entries from captured_enemy dictionary
		lasso.captured_enemies.erase(body)
		

func _on_sense_range_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("captured"):
		sense_range.body_entered.connect(body._on_alarmed)
	sense_range.emit_signal("body_entered")

