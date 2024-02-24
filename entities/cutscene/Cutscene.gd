extends Area2D

export(Array, String, MULTILINE) var dialog : Array

onready var player = get_tree().current_scene.get_node_or_null("Knight")
onready var player_camera = player.get_node("Camera2D")

onready var animation_player = $AnimationPlayer
onready var label = $CanvasLayer/BlackBarBottom/Label

var i = 0

func play_cutscene():
	player.freeze = true
	player_camera.track_player = false
	player_camera.global_position = get_parent().global_position
	
	label.text = dialog[i]
	animation_player.play("start")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not animation_player.is_playing():
		if i == dialog.size()-1:
			animation_player.play("end")
			i = 0
			
			player.freeze = false
			player_camera.track_player = true
			player_camera.global_position = player.global_position
		else:
			i += 1
			label.text = dialog[i]
			animation_player.play("talk")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		animation_player.play("talk")

func _on_Cutscene_area_entered(area):
	if area.name == "SenseRange":
		play_cutscene()
