extends KinematicBody2D

onready var sprite = $AnimatedSprite
onready var cutscene = $Cutscene

func _on_Hitbox_area_entered(area):
	if area.name == "SenseRange":
		cutscene.dialog = "Help! Save me LassoKnight!"
		cutscene.play_cutscene()
