extends CanvasLayer

export(Texture) var texture
export(String) var dialog

onready var player = get_tree().current_scene.get_node_or_null("Knight")
onready var player_camera = player.get_node("Camera2D")

onready var animation_player = $AnimationPlayer
onready var label = $BlackBarBottom/Label

func play_cutscene():
	label.text = dialog
	animation_player.play("talk")
	
	player.freeze = true
	player_camera.track_player = false
	player_camera.global_position = get_parent().global_position

func _process(_delta):
	if Input.is_action_just_pressed("whip") and not animation_player.is_playing():
		animation_player.play("end")
		
		player.freeze = false
		player_camera.track_player = true
