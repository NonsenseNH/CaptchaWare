extends Microgame

@onready var nuclearanimcutscene: AnimationPlayer = $nuclearanimcutscene
@onready var monitors_text_sprites: Sprite2D = $nuclear/Monitors

@onready var sound_press: AudioStreamPlayer = $nuclear/Monitors/press
@onready var sound_it: AudioStreamPlayer = $nuclear/Monitors/it

@onready var the_main_code : Node2D = get_tree().get_first_node_in_group("main_game")
@onready var audio: AudioStreamPlayer = $audio

var cur_monitor_frame := false
var activate_monitors : = true

func on_transition_complete() -> void:
	monitors()

func monitors() -> void:
	if !activate_monitors: return
	monitors_text_sprites.frame = int(cur_monitor_frame)
	
	if cur_monitor_frame:
		sound_it.play()
	else:
		sound_press.play()
	
	await get_tree().create_timer(1).timeout
	
	cur_monitor_frame = !cur_monitor_frame
	monitors()

func _on_nuke_button_pressed() -> void:
	nuclearanimcutscene.play("press")
	activate_monitors = false
	monitors_text_sprites.frame = 2
	
	var music : AudioStreamPlayer = the_main_code.music
	if music.playing:
		music.stream_paused = true

func isWinning() -> bool:
	return true

func canSkip() -> bool:
	return false

func shake_launch_nuke(shake : bool) -> void:
	set_camera_shake.emit(5 if shake else 0, 0)

func _on_nuclearanimcutscene_animation_finished(anim_name: StringName) -> void:
	if anim_name != "press": return
	force_end_mircogame()
	
	var fade_out := create_tween()
	fade_out.tween_property(audio, "volume_db", -30, 1)
