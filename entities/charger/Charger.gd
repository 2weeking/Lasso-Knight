extends CharacterBody2D
@export var walkspeed = 50
@export var runspeed = 70
@export var damage : int = 1
var currentspeed = 50

@onready var player = get_parent().get_node("Knight")
@onready var timer = $Timer

func _ready():
	timer.timeout.connect(_timeout)

func _physics_process(delta):
	if(!timer.is_stopped()):
		timer.start(7)
		currentspeed = walkspeed
	
	if is_instance_valid(player):
		#position = position.lerp(player.position, speed * delta)
		var direction = (player.position - position).normalized()
		velocity = direction * currentspeed
	
	move_and_collide(velocity * delta)
	
func _timeout():
	currentspeed = runspeed
	timer.start(2)
