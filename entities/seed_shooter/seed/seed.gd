extends CharacterBody2D

@export var speed = 300
@export var damage = 1
@export var knockback_strength = 600
@onready var player = get_parent().get_node("Knight")
@onready var shooter = get_parent()

func _ready():
	velocity = (player.position-shooter.position).normalized()*speed

func _physics_process(_delta):
	move_and_slide()

func _on_alarmed():
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_hitbox_area_entered(area):
	if area.name == "Hitbox" and not is_in_group("captured"):
		var body = area.get_parent()
		
		# Deal damage
		body.hp -= damage
		
		# Deal knockback
		var knock_direction = global_position.direction_to(body.global_position)
		body.knockback = knock_direction * knockback_strength
		
		queue_free()
