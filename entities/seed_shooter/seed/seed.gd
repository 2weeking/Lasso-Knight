extends CharacterBody2D

@export var speed = 300
@export var damage = 1
@onready var player = get_parent().get_node("Knight")
@onready var shooter = get_parent()

func _ready():
	velocity = (player.position-shooter.position).normalized()*speed
	add_to_group("enemy")
	
func _physics_process(delta):
	move_and_slide()



func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
