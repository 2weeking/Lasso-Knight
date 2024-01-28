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
@export var constraint : float = 10.0

@onready var hurtbox = $HurtBox

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var rope_obj = preload("res://entities/lasso/rope.tscn")
@onready var rope_end_piece = preload("res://entities/lasso/rope_end_piece.tscn")

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
	
	velocity = input_direction * move_speed
	
	for body in bodies:
		if (int(velocity.x) ^ int(body.velocity.x)) < 0:
			print(body.velocity.normalized())
			if abs(velocity.x - body.velocity.x) < constraint:
				body.velocity = Vector2.ZERO
			velocity += body.velocity
	
	move_and_slide()

func add_new_rope(body):
	body.add_to_group("captured")
	var rope = rope_obj.instantiate()
	var rope_start = rope_end_piece.instantiate()
	add_child(rope_start)
	var rope_end = rope_end_piece.instantiate()
	body.add_child(rope_end)
	rope.rope_start_piece = rope_start
	rope.rope_end_piece = rope_end
	get_parent().add_child(rope)
	rope.spawn_rope()

func _on_hit_box_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		hp -= body.damage
func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemies") and not body.is_in_group("captured"):
		call_deferred("add_new_rope", body)
		bodies.append(body)
