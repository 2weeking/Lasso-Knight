extends Control

func _ready():
	randomize()

func _on_Enter_pressed():
	if get_tree().change_scene_to_file("res://levels/level_0.tscn") != OK:
		print("An unexpected error occured when trying to switch to the World scene")

func _on_Quit_pressed():
	get_tree().quit()
