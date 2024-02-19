extends KinematicBody2D

onready var sprite = $AnimatedSprite
onready var cutscene = $Cutscene

func _on_Hitbox_area_entered(area):
	if area.name == "SenseRange":
		cutscene.dialog = "Hey there young buck! You think you could help me out here in putting my cattle back in their pen? Thanks!"
		cutscene.play_cutscene()
