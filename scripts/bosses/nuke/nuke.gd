extends Microgame

@onready var nuclearanimcutscene: AnimationPlayer = $nuclearanimcutscene
@onready var monitors_text_sprites: Sprite2D = $nuclear/Monitors

@onready var the_main_code : Node2D = get_tree().get_first_node_in_group("main_game")

var cur_monitor_frame := false
var activate_monitors : = true

func _ready() -> void:
	monitors()

func monitors() -> void:
	if !activate_monitors: return
	monitors_text_sprites.frame = int(cur_monitor_frame)
	
	await get_tree().create_timer(1).timeout
	
	cur_monitor_frame = !cur_monitor_frame
	monitors()

func _on_nuke_button_pressed() -> void:
	nuclearanimcutscene.play("press")
	activate_monitors = false
	monitors_text_sprites.frame = 2
	
	var music : AudioStreamPlayer = the_main_code.music
	if music.playing:
		music.paused = true
