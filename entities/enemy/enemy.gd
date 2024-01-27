extends CharacterBody2D
var alarmed = false
@export var speed = 50
@export var damage : int = 1

@onready var player = get_parent().get_node("Knight")

func _physics_process(delta):
	if is_instance_valid(player) and alarmed:
		#position = position.lerp(player.position, speed * delta)
		var direction = (player.position - position).normalized()
		velocity = direction * speed
	
	move_and_collide(velocity * delta)
	
func _on_alarmed():
	var direction = (player.position - position).normalized()
	velocity = direction*speed
	alarmed = true
