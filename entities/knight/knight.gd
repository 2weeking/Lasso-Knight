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
@export var lasso_speed : float = 2.0

@onready var lasso = preload("res://entities/lasso/verlet_rope.tscn")
@onready var hurtbox = $HurtBox

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var desired_velocity = Vector2.ZERO

var bodies = []

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
	if Input.is_action_just_pressed("whip") and not animation_player.is_playing():
		hurtbox.look_at(get_global_mouse_position())
		animation_player.play("attack")
	
	desired_velocity = input_direction * move_speed
	
	velocity = desired_velocity
	
	for body in bodies:
		velocity -= body.desired_velocity
	
	move_and_slide()


var verlet_rope = preload("res://entities/lasso/verlet_rope.tscn")

func add_new_rope(body):
	var rope = verlet_rope.instantiate()
	rope.origin = self
	rope.target = body
	get_parent().add_child(rope)

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("captured"):
		hp -= body.damage

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not body.is_in_group("captured"):
		call_deferred("add_new_rope", body)
		body.add_to_group("capturing")
		bodies.append(body)
