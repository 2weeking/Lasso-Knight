extends KinematicBody2D

onready var current_scene = get_tree().get_current_scene()
onready var sprite = $AnimatedSprite
onready var cutscene = $Cutscene

func areEnemiesRemaining() -> bool:    
	# Iterate through all nodes in the scene
	for node in current_scene.get_children():
		# Check if the node belongs to the "enemy" group
		if node.is_in_group("enemy"):
			return true
	
	return false


func _on_Hitbox_area_entered(area):
	if area.name == "SenseRange":
		if areEnemiesRemaining():
			cutscene.dialog = "Hey there young buck! I hate to be a bother, but I sure could use some help gettin' them cattle back in their pen. I appreciate it mister!"
			cutscene.play_cutscene()
		else:
			sprite.flip_h = false
			sprite.play("mad")
			cutscene.dialog = "MY CATTLE! WHAT HAVE YOU DONE!!!!!! YOU WILL PAY FOR THIS!!!!!!"
			cutscene.play_cutscene()
