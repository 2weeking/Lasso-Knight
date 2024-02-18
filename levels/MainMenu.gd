extends Control

func _ready():
	randomize()

func _on_Start_pressed():
	if get_tree().change_scene("res://levels/Level1.tscn") != OK:
		print_debug("An unexpected error occured when trying to switch to the World scene")
