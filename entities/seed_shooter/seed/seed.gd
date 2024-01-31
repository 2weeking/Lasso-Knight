extends Area2D

@onready var player = get_parent().get_parent().get_node("knight")
@onready var father_shooter = get_parent().get_parent().get_node("SeedShooter")
var speed = 50
var direction
# Called when the node enters the scene tree for the first time.
func _ready():
	var direction = (player.position - father_shooter.position).normalized()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta)
