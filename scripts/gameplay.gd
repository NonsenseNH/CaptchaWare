extends SaveSystem

const JSON_FILE_LOCATION : String = "res://scripts/microgames/microgames.json"
const JUDGEMENT_TEXT_LOCATION : String = "res://scripts/"

@export_enum("normal", "absurd", "all") var cur_microgame_pool : String = "all"

@export var cur_speed : float = 1
@onready var original_speed := cur_speed

@export var games_left_to_speed_up : = 5
@export var games_on_intro := 3
var intro_sequence := true

@onready var bg: TextureRect = $bg

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader

@onready var timer: Timer = $Timer
@onready var cur_wait_time := timer.wait_time
@onready var total_wait_time := cur_wait_time
@onready var og_wait_time := cur_wait_time

@onready var captcha_window: TextureRect = $window/captcha_window
@onready var captcha_input_disabler: ColorRect = $window/captcha_window/blocker
@onready var captcha_transition: AnimationTree = $captchaTransition
@onready var captcha_anim_tree : AnimationNodeStateMachinePlayback = captcha_transition["parameters/playback"]
@onready var captcha_animation_player: AnimationPlayer = $captchaTransition/captchaAnimationPlayer
@onready var error_message: Label = $"../MainMenu/captchabox/captchaSprite/ErrorMessage"
@onready var captcha_bg: TextureRect = $bg

@onready var camera: Camera2D = $camera
@onready var intermission_text: Control = $window/intermissionText/judgement
@onready var ui_captcha_window: Control = $window
@onready var sounds: Node = $sounds
@onready var music: AudioStreamPlayer = $captchaTransition/captchaAnimationPlayer/Mosik

@onready var verify_button: Button = $window/captcha_window/lowbar/verifyButton

var prev_microgame : Node = null
var cur_window_size : Vector2 = Vector2.ZERO

var cur_microgame : Node = null
var transitioning : bool = false

var cur_microgame_pool_array : PackedStringArray = []

var games_played : int = 0

var microgame_json : Dictionary = {}
var cur_microgame_data : Dictionary = {}

var prev_window_size : Vector2 = Vector2.ZERO

var judgement_text : Dictionary = {
	"win_dialogue": {},
	"lose_dialogue": {}
}
@onready var judgement_text_intro: Label = $window/intermissionText/judgementTextIntro

var difficulty : int = 1

var game_started := false

var ui_data : Dictionary = {
	"instructionsBig" : "",
	"InstructionsSmall" : "",
	"referenceImage" : "",
	
	"windowSize" : Vector2.ZERO,
	"windowTween" : false,
	"tweenSpeed" : 1
}

var musicState : String = "Captchaware Game"

var win_streak : int = 0

var fails : int = 0

signal on_transition_complete

func _ready() -> void:
	var file := FileAccess.open(JUDGEMENT_TEXT_LOCATION + "win_judgement_text.txt", FileAccess.READ)
	judgement_text.win_dialogue = file.get_as_text().split(",", false)
	
	file = FileAccess.open(JUDGEMENT_TEXT_LOCATION + "lose_judgement_text.txt", FileAccess.READ)
	judgement_text.lose_dialogue = file.get_as_text().split(",", false)
	
	microgame_json = JSON.parse_string(FileAccess.open(JSON_FILE_LOCATION, FileAccess.READ).get_as_text())
	
	for game in microgame_json.microgames.keys():
		resource_preloader.add_resource(game, load("res://microgames/" + game + ".tscn"))

func start_game() -> void:
	intro_sequence = true

	captcha_input_disabler.visible = false
	
	var bus_index = AudioServer.get_bus_index("Microgame Sounds")
	AudioServer.set_bus_volume_db(bus_index, -80)
	
	fails = 0
	win_streak = 0
	games_played = 0
	
	if intro_sequence:
		captcha_transition.set("parameters/conditions/intro", true)
		cur_microgame_pool_array = get_game_pool("normal")
	else:
		cur_microgame_pool_array = get_game_pool()
	
	error_message.visible = false

	get_microgame_data("imageLocation")

	prev_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

	set_up_window_size()
	set_game_speed()
	change_game()
	
	reset_fail_count()
	
	captcha_animation_player.play("gameIntro")
	
	captcha_transition.set("parameters/conditions/speed up", false)
	captcha_transition.set("parameters/conditions/no lives", false)
	game_started = true

func get_game_pool(_pool_override : String = "") -> Array:
	if cur_microgame_pool.to_lower() == "all" && _pool_override == "":
		var cur_array := []
		for i in microgame_json.microgame_pool:
			cur_array.append_array(microgame_json.microgame_pool[i])
			
		return cur_array
	else:
		return microgame_json.microgame_pool[cur_microgame_pool if _pool_override == "" else _pool_override]

func set_game_speed(speed: float = 0) -> void:
	var anim_speed := maxf(speed * 1.15, 3.0)
	var wait_time := maxf(cur_wait_time - ((cur_wait_time / 2) / og_wait_time), 3.0)
	if speed == 0.0:
		music.pitch_scale = 1
		cur_speed = original_speed
		cur_wait_time = og_wait_time
		difficulty = 1
		
		bg.material.set("shader_parameter/scroll_speed", 0.01)
		
		for anim in captcha_animation_player.get_animation_list():
			if anim == "RESET": continue
			captcha_transition.set("parameters/" + anim + "/TimeScale/scale", 1)
		return
	
	var added_speed := speed / (cur_speed + speed)
	
	cur_speed += added_speed
	
	cur_wait_time = wait_time if wait_time > 3.0 else cur_wait_time - 0.05
	
	for anim in captcha_animation_player.get_animation_list():
		if anim == "RESET": continue
		captcha_transition.set("parameters/" + anim + "/TimeScale/scale", anim_speed)
	
	if difficulty < 4:
		difficulty += 1
	
	var captcha_bg_tween : Tween = create_tween()
	captcha_bg_tween.tween_property(bg.material, "shader_parameter/scroll_speed", speed, 3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).as_relative()

func set_up_window_size(tween_window: bool = false) -> void:
	ui_captcha_window.set_up_ui_data({
		"windowSize" : Vector2(cur_microgame_data.Width, cur_microgame_data.Length),
		"windowTween" : tween_window,
		"tweenSpeed" : minf(cur_speed * 0.8, 2.3)
	})

	if prev_window_size == Vector2(cur_microgame_data.Width, cur_microgame_data.Length):
		return
	
	prev_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

	sounds.get_node("stretch resize").play()

func _on_timer_timeout() -> void:
	transition_game()

func transition_game() -> void:
	captcha_input_disabler.visible = true

	var did_fail : bool = prev_microgame != null && !prev_microgame.isWinning()
	
	cur_microgame.stop_microgame()
	play_captcha_anim_tree()
	
	transitioning = true
	
	games_played += 1
	
	ui_captcha_window._display_error_text("", true)
	
	if !intro_sequence:
		music_handler(did_fail)
	
	get_microgame_data()

	sounds.get_node("ding").volume_db = -19.0 if !did_fail else -80.0
	
	if intro_sequence: 
		judgement_text_intro.text = "Good!" if !did_fail else "Try Again!"
		if games_played >= 3:
			intro_sequence = false
			games_played = 0
			captcha_transition.set("parameters/conditions/speed up", true)
			cur_microgame_pool_array.clear()
			
			var bus_index = AudioServer.get_bus_index("Microgame Sounds")
			AudioServer.set_bus_volume_db(bus_index, 0)
		return
	
	set_judgement_text(did_fail)
	
	if did_fail:
		fails += 1
		if fails >= 4: 
			game_over()
	
	var can_speed_up := games_played % games_left_to_speed_up == 0
	
	captcha_transition.set("parameters/conditions/speed up", can_speed_up)
	if can_speed_up:
		set_game_speed(1)
	
	captcha_transition.set("parameters/conditions/failed", did_fail)

func game_over() -> void:
	disconnect_prev_microgame_signals()

	captcha_transition.set("parameters/conditions/no lives", true)
	error_message.visible = true
	game_started = false

func disconnect_prev_microgame_signals() -> void:
	if prev_microgame == null: return
	on_transition_complete.disconnect(prev_microgame.on_transition_complete)
	prev_microgame.override_instruction_text.disconnect(override_instructions)
	prev_microgame.set_camera_shake.disconnect(camera_shake)
	prev_microgame.skip_timer.disconnect(skip_timer)
	prev_microgame.end_microgame.disconnect(transition_game)

func music_handler(has_failed : bool) -> void:
	if !music.playing:
		music.play()
	
	if has_failed:
		win_streak = 0
		music.get_stream_playback().switch_to_clip_by_name("Captchaware Failed")
		musicState = "Captchaware Game"
		return
	
	win_streak += 1
	
	if win_streak >= 4:
		musicState = "Captchaware Win"
	else:
		musicState = "Captchaware Game"
	
	music.get_stream_playback().switch_to_clip_by_name(musicState)

func end_intro_sequence() -> void:
	music.play()
	music.get_stream_playback().switch_to_clip_by_name("Captchaware Game Slow" if cur_microgame_data.slowGame else "Captchaware Game")
	
	captcha_transition.set("parameters/conditions/intro", false)
	
	if captcha_bg.self_modulate.a != 0.0: return
	
	var captcha_bg_tween : Tween = create_tween()
	captcha_bg_tween.tween_property(captcha_bg, "self_modulate", Color("e3e3e35a"), 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func play_captcha_anim_tree() -> void:
	captcha_transition.active = false
	captcha_transition.active = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click"):
			sounds.get_node("mouse click down").play()
		
		if Input.is_action_just_released("Left Click"):
			sounds.get_node("mouse click up").play()
	
	if event is InputEventKey:
		if event.is_pressed() && !event.is_echo():
			sounds.get_node("keyboard typing").play()
	
	if !game_started: return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_text_submit") && !verify_button.disabled:
			skip_game()

func set_judgement_text(failed : bool = false) -> void:
	var dialogue : String
	if failed:
		dialogue = judgement_text.lose_dialogue[randi_range(0, judgement_text.lose_dialogue.size() - 1)]
	else:
		dialogue = judgement_text.win_dialogue[randi_range(0, judgement_text.win_dialogue.size() - 1)]
	
	intermission_text.get_node("judgementText").text = dialogue.strip_edges()

#region ANIMATION FUNCTIONS

func count_fail_attempt() -> void:
	var cur_slot : Control = intermission_text.get_node("attemptBars").get_child(clampi(fails-1,0,3))
	cur_slot.get_child(0).self_modulate = Color(1,1,1,1)
	
	intermission_text.get_node("attempts").text = str(mini(fails, 4)) + " of 4 failed attempts"
	
	camera.shake_camera(10, 0.3)

func reset_fail_count() -> void:
	var cur_slot : Array = intermission_text.get_node("attemptBars").get_children()
	intermission_text.get_node("attempts").text = str(mini(fails, 4)) + " of 4 failed attempts"
	for slot in cur_slot:
		slot.get_child(0).self_modulate = Color(0,0,0,0.384)

func set_up_game() -> void:
	remove_game()
	
	set_up_window_size(true)

func remove_game() -> void:
	if prev_microgame != null:
		ui_captcha_window.cur_game.remove_child(prev_microgame)

func change_game():
	if music.playing:
		music.get_stream_playback().switch_to_clip_by_name("Captchaware Game Slow" if cur_microgame_data.slowGame else musicState)
	
	cur_microgame.z_index += 1
	
	disconnect_prev_microgame_signals()
	
	on_transition_complete.connect(cur_microgame.on_transition_complete)
	cur_microgame.override_instruction_text.connect(override_instructions)
	cur_microgame.set_camera_shake.connect(camera_shake)
	cur_microgame.skip_timer.connect(skip_timer)
	cur_microgame.end_microgame.connect(transition_game)
	
	cur_microgame.current_game_speed = cur_speed
	cur_microgame.difficulty = difficulty
	cur_microgame.is_intro = intro_sequence
	
	override_instructions(cur_microgame_data.instructionsBig, cur_microgame_data.InstructionsSmall, cur_microgame_data.referenceImage)
	
	ui_captcha_window.cur_game.add_child(cur_microgame)
	
	cur_microgame.global_position = ui_captcha_window.cur_game.global_position
	
	prev_microgame = cur_microgame
	
	if !intro_sequence && !cur_microgame_data.noTimer:
		if cur_microgame_data.has("staticTimer") && cur_microgame_data.staticTimer:
			total_wait_time = og_wait_time + cur_microgame_data.BonusTime
		else:
			total_wait_time = cur_wait_time + cur_microgame_data.BonusTime
		timer.wait_time = total_wait_time
		timer.start()
	transitioning = false
#endregion

#region MICROGAME SIGNAL FUNCTIONS
func override_instructions(big:String = "..n",small:String = "..n",ref:String = "..n") -> void:
	var txt : Array = [big,small,ref]
	for text_index in range(txt.size()):
		if txt[text_index] == "":
			txt[text_index] = "..n"
	
	ui_data = {
		"instructionsBig" : txt[0],
		"InstructionsSmall" : txt[1],
		"referenceImage" : txt[2],
	}
	ui_captcha_window.set_up_ui_data(ui_data)

func camera_shake(intensity : float, duration : float) -> void:
	camera.shake_camera(intensity, duration)

func skip_timer() -> void:
	var skip_time_to : int = 1
	
	if timer.time_left < skip_time_to: return
	timer.wait_time = skip_time_to
	timer.start()
#endregion

func get_microgame(force_game : String = "") -> Node:
	var cur_game : Node
	var cur_game_name : String = ''
	
	if force_game != "":
		cur_game = resource_preloader.get_resource(force_game).instantiate()
		return cur_game
	
	if cur_microgame_pool_array.is_empty():
		cur_microgame_pool_array = get_game_pool()
	
	while (true):
		cur_game_name = cur_microgame_pool_array[randi_range(0, cur_microgame_pool_array.size() - 1)]
		if (cur_game_name == null || !(prev_microgame == null || cur_game_name != prev_microgame.name) && cur_microgame_pool_array.size() != 1): continue
		break
	
	cur_game = resource_preloader.get_resource(cur_game_name).instantiate()
	
	cur_microgame_pool_array.erase(cur_game_name)
	
	return cur_game

func get_microgame_data(force_game: String = "") -> void:
	cur_microgame = get_microgame(force_game)
	
	cur_microgame_data = microgame_json.microgames[cur_microgame.name]
	cur_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

func skip_game() -> void:
	if transitioning: return
	
	if cur_microgame.canSkip():
		timer.stop()
		transition_game()
	else:
		ui_captcha_window._display_error_text(microgame_json.microgames[cur_microgame.name].errorMessage)


func checkbox_pressed() -> void:
	start_game()


func _on_captcha_animation_player_animation_finished(anim_name: StringName) -> void:
	if !["gametransition_end", "gametransition_speedup", "gametransition_gameover", "gametransition_speedup_beginning"].has(anim_name): return
	if anim_name != "gametransition_gameover":
		on_transition_complete.emit()
	captcha_input_disabler.visible = false
