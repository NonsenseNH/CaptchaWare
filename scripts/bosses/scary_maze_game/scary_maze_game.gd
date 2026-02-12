extends Microgame

@onready var levels: Control = $levels
@onready var jumpscare_texture: TextureRect = $Jumpscare
@onready var jumpscare_sound: AudioStreamPlayer = $"jumpscare sound"

var cur_level := 0

var beaten_game := false

const TOTAL_LEVELS := 3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	reset_levels()

func change_level(level: int) -> void:
	for i in range(levels.get_child_count()):
		if i == level:
			continue
		var cur_level_child := levels.get_child(i)
		cur_level_child.visible = false
	
	levels.get_child(level).visible = true

func _on_start_button_pressed() -> void:
	proceed_to_next_level()

func proceed_to_next_level() -> void:
	cur_level += 1
	change_level(cur_level)

func canSkip() -> bool:
	return false

func isWinning() -> bool:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return beaten_game

func reset_levels() -> void:
	cur_level = 0
	change_level(cur_level)

func _on_savezone_area_exited(_area: Area2D) -> void:
	reset_levels()

func _on_victory_zone_area_entered(_area: Area2D) -> void:
	proceed_to_next_level()

func jumpscare(_area: Area2D) -> void:
	reset_levels()
	beaten_game = true
	jumpscare_texture.visible = true
	jumpscare_sound.play()

	await get_tree().create_timer(2.0).timeout

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	end_microgame.emit()
