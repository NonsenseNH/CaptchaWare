extends TextureRect

class_name LevelMaze

@onready var hazard: Area2D = $hazard
@onready var victory_zone: Area2D = $victoryZone

func _on_visibility_changed() -> void:
	hazard.set_deferred("monitoring", visible)
	victory_zone.set_deferred("monitoring", visible)
