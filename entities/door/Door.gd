extends KinematicBody2D

export(String, FILE, "*.tscn,*.scn") var scene_path setget set_scene_path

func set_scene_path(p_value):
	if typeof(p_value) == TYPE_STRING and p_value.get_extension() in ["tscn", "scn"]:
		var d = Directory.new()
		if not d.file_exists(p_value):
			return
		scene_path = p_value

onready var sprite = $AnimatedSprite

func _on_Hitbox_area_entered(area):
	if area.name == "Hitbox" and area.get_parent().is_in_group("player"):
		if get_tree().change_scene(scene_path) != OK:
			print_debug("An unexpected error occured when trying to switch scene")
