extends CanvasLayer

@onready var player = get_parent().get_parent()
@onready var HealthUIFull = $HealthUIFull

func _ready():
	if player:
		player.hp_changed.connect(_on_player_hp_changed)

func _on_player_hp_changed(_hp, new_hp):
	if new_hp >= 0:
		HealthUIFull.size.x = new_hp * 16
