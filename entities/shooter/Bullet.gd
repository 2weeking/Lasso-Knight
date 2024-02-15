extends KinematicBody2D

export var speed = 300
export var damage = 1
export var knockback_strength = 600
onready var player = get_parent().get_node("Knight")
onready var shooter = get_parent()

var velocity := Vector2.ZERO

func _ready():
	velocity = (player.position-shooter.position).normalized()*speed

func _physics_process(_delta):
	velocity = move_and_slide(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Hurtbox_area_entered(area):
	if area.name == "Hitbox":
		queue_free()
