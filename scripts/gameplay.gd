extends Node2D

const JSON_FILE_LOCATION : String = "res://scripts/microgames/microgames.json"
const JUDGEMENT_TEXT_LOCATION : String = "res://scripts/"

const TOTAL_CAPTCHAS := 20

@export_enum("normal", "absurd", "all", "campaign") var cur_microgame_pool : String = "all"

@export var cur_speed : float = 1
@onready var original_speed := cur_speed

@export var games_left_to_speed_up : int = 5
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

var prev_microgame : Microgame = null
var cur_window_size : Vector2 = Vector2.ZERO

var cur_microgame : Microgame = null
var transitioning : bool = false

var cur_microgame_pool_array : PackedStringArray = []

var games_played : int = 0

var microgame_pool_json : Dictionary = {}

var cur_microgame_data : Dictionary = {
	"instructionsBig" : "",
	"InstructionsSmall" : "",
	"referenceImage" : null,
	"errorMessage" : "",
	"Length": 0,
	"Width": 0,
	"bonusTime": 0,
	"slowGame": false,
	"staticTimer" : false,
	"noTimer" : false
}

var prev_window_size : Vector2 = Vector2.ZERO

var judgement_text : Dictionary = {
	"win_dialogue": {},
	"lose_dialogue": {}
}
@onready var judgement_text_intro: Label = $window/intermissionText/judgementTextIntro

@onready var scores: Control = $window/captcha_window/blueBorder/scores

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
	
	microgame_pool_json = JSON.parse_string(FileAccess.open(JSON_FILE_LOCATION, FileAccess.READ).get_as_text())
	
	var game_name_list := ResourceLoader.list_directory("res://microgames/")

	for game in game_name_list:
		resource_preloader.add_resource(game.replace(".tscn", ""), load("res://microgames/" + game))

func start_game() -> void:
	intro_sequence = true

	captcha_input_disabler.visible = false
	
	var bus_index = AudioServer.get_bus_index("Microgame Sounds")
	AudioServer.set_bus_volume_db(bus_index, -80)
	
	cur_microgame_pool = "all" if GameData.save_file.endless_mode else "campaign"
	
	fails = 0
	win_streak = 0
	games_played = 0
	
	if intro_sequence:
		captcha_transition.set("parameters/conditions/intro", true)
		cur_microgame_pool_array = get_game_pool("normal")
	else:
		cur_microgame_pool_array = get_game_pool(cur_microgame_pool)
	
	error_message.visible = false

	get_microgame_data("imageLocation")

	prev_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

	set_up_window_size()
	set_game_speed()
	change_game()
	
	reset_fail_count()
	
	captcha_animation_player.play("gameIntro")
	
	captcha_transition.set("parameters/conditions/boss", false)
	captcha_transition.set("parameters/conditions/speed up", false)
	captcha_transition.set("parameters/conditions/no lives", false)
	game_started = true

func get_game_pool(pool_override : String) -> Array:
	if pool_override.to_lower() == "all":
		var cur_array := []
		
		cur_array = microgame_pool_json[pool_override]

		while true:
			cur_array.shuffle()

			if cur_array[0] != prev_microgame.name: break
		
		return cur_array
	else:
		return microgame_pool_json[pool_override]

func set_game_speed(speed: float = 0) -> void:
	if speed == 0.0:
		music.pitch_scale = 1
		cur_speed = original_speed
		cur_wait_time = og_wait_time
		difficulty = 1
		
		for anim in captcha_animation_player.get_animation_list():
			if anim == "RESET": continue
			captcha_transition.set("parameters/" + anim + "/TimeScale/scale", 1)
		return
	
	var anim_speed := maxf(speed * 1.15, 3.0)
	var wait_time := maxf(cur_wait_time - ((cur_wait_time / 2) / og_wait_time), 3.0)
	var added_speed := speed / (cur_speed + speed)
	
	cur_speed += added_speed
	
	if cur_wait_time >= 2.0:
		cur_wait_time = wait_time if wait_time > 3.0 else cur_wait_time - 0.1
	
	for anim in captcha_animation_player.get_animation_list():
		if anim == "RESET": continue
		captcha_transition.set("parameters/" + anim + "/TimeScale/scale", anim_speed)
	
	if difficulty < 4:
		difficulty += 1

func get_boss_game() -> void:
	set_game_speed(0)
	captcha_transition.set("parameters/conditions/boss", true)
	
	var boss_int := 0
	if GameData.stored_data.previous_boss == 0:
		boss_int = randi_range(0, 1)
	else:
		boss_int = int(GameData.stored_data.previous_boss == 1)
	GameData.stored_data.previous_boss = boss_int + 1
	get_microgame_data(microgame_pool_json["bosses"][boss_int])

func set_up_window_size(tween_window: bool = false, play_sound := true, size_override : Vector2 = Vector2.ZERO) -> void:
	ui_captcha_window.set_up_ui_data({
		"windowSize" : size_override if size_override != Vector2.ZERO else Vector2(cur_microgame_data.Width, cur_microgame_data.Length),
		"windowTween" : tween_window,
		"tweenSpeed" : minf(cur_speed * 0.8, 2.3)
	})

	if prev_window_size == Vector2(cur_microgame_data.Width, cur_microgame_data.Length):
		return
	
	prev_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

	if play_sound: sounds.get_node("stretch resize").play()

func _on_timer_timeout() -> void:
	cur_microgame.end_microgame.emit()

func win() -> void:
	var prev_microgame_anim_name : String = prev_microgame.microgame_data.ending_cutscene_name
	if captcha_animation_player.has_animation(prev_microgame_anim_name):
		captcha_animation_player.play(prev_microgame_anim_name)
	else:
		captcha_animation_player.play("gametransition_final_ending_1")
	end_game()

func transition_game() -> void:
	if cur_microgame_pool == "campaign" && games_played >= TOTAL_CAPTCHAS:
		win()
		return

	if prev_microgame != null && prev_microgame.skipped: return

	captcha_input_disabler.visible = true
	prev_microgame.skipped = true

	var did_fail : bool = prev_microgame != null && !prev_microgame.isWinning()
	
	cur_microgame.stop_microgame()
	play_captcha_anim_tree()
	
	transitioning = true

	games_played += 1
	
	ui_captcha_window._display_error_text("", true)
	
	if !intro_sequence:
		music_handler(true, did_fail)
	
	if cur_microgame_pool == "campaign" && games_played == TOTAL_CAPTCHAS:
		get_boss_game()
	else:
		get_microgame_data()

	sounds.get_node("ding").volume_db = -19.0 if !did_fail else -80.0

	timer.stop()
	
	if intro_sequence: 
		judgement_text_intro.text = "Good!" if !did_fail else "Try Again!"
		if games_played >= games_on_intro:
			intro_sequence = false
			games_played = 0
			captcha_transition.set("parameters/conditions/speed up", true)

			cur_microgame_pool_array.clear()
			get_microgame_data() #this is to actually get the data from the updated pool
			
			var bus_index = AudioServer.get_bus_index("Microgame Sounds")
			AudioServer.set_bus_volume_db(bus_index, 0)
		return
	
	ui_captcha_window.set_score_num(games_played)
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
	set_game_speed(0)
	scores.visible = GameData.save_file.endless_mode
	
	end_game()
	
	captcha_transition.set("parameters/conditions/no lives", true)
	error_message.visible = true
	
	if !GameData.save_file.endless_mode: return
	if games_played > GameData.save_file.highscore && GameData.save_file.endless_mode:
		GameData.save_file.highscore = games_played
		GameData.save_cur_data(GameData.GAME_SAVE_NAME)
	
	scores.get_child(0).text = "Captchas Solved: " + str(games_played) 
	scores.get_child(1).text = "Most Captchas: " + str(GameData.save_file.highscore)

func end_game() -> void:
	disconnect_prev_microgame_signals()
	game_started = false

func disconnect_prev_microgame_signals() -> void:
	if prev_microgame == null || !on_transition_complete.is_connected(prev_microgame.on_transition_complete): return
	on_transition_complete.disconnect(prev_microgame.on_transition_complete)
	prev_microgame.override_instruction_text.disconnect(override_instructions)
	prev_microgame.set_camera_shake.disconnect(camera_shake)
	prev_microgame.skip_timer.disconnect(skip_timer)
	prev_microgame.end_microgame.disconnect(transition_game)
	prev_microgame.freeze_timer_signal.disconnect(freeze_timer)

func freeze_timer() -> void:
	timer.paused = true

func music_handler(intermission : bool = false, has_failed : bool = false, reset_music : = false) -> void:
	if !music.playing || reset_music:
		music.play()
	
	if intermission:
		win_streak += 1

		if has_failed:
			win_streak = 0
			musicState = "Captchaware Failed"
		else:
			_streak_music_check()
		
	else:
		if cur_microgame_data.slowGame:
			musicState = "Captchaware Game Slow"
		else:
			_streak_music_check()
	
	music.get_stream_playback().switch_to_clip_by_name(musicState)

func _streak_music_check():
	if win_streak >= 7:
		musicState = "Captchaware Win"
	else:
		musicState = "Captchaware Game"

func end_intro_sequence() -> void:
	music_handler(false, false, true)
	
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

func set_up_game(play_sound := true) -> void:
	remove_game()
	
	set_up_window_size(true, play_sound)

func remove_game() -> void:
	if prev_microgame != null:
		ui_captcha_window.cur_game.remove_child(prev_microgame)

func change_game(is_boss := false) -> void:
	if cur_microgame == null: 
		print_debug("Current microgame is null!")
		return
	if music.playing && !is_boss:
		music_handler(false, false)
	
	cur_microgame.z_index += 1
	
	disconnect_prev_microgame_signals()
	
	on_transition_complete.connect(cur_microgame.on_transition_complete)
	cur_microgame.override_instruction_text.connect(override_instructions)
	cur_microgame.set_camera_shake.connect(camera_shake)
	cur_microgame.skip_timer.connect(skip_timer)
	cur_microgame.end_microgame.connect(transition_game)
	cur_microgame.freeze_timer_signal.connect(freeze_timer)
	
	cur_microgame.current_game_speed = cur_speed
	cur_microgame.difficulty = difficulty
	cur_microgame.is_intro = intro_sequence
	
	override_instructions(cur_microgame_data.instructionsBig, cur_microgame_data.instructionsSmall, cur_microgame_data.referenceImage)
	
	ui_captcha_window.cur_game.add_child(cur_microgame)
	
	cur_microgame.global_position = ui_captcha_window.cur_game.global_position
	
	prev_microgame = cur_microgame
	
	if !intro_sequence && !cur_microgame_data.noTimer:
		timer.paused = false
		if cur_microgame_data.has("staticTimer") && cur_microgame_data.staticTimer:
			total_wait_time = og_wait_time + cur_microgame_data.bonusTime
		else:
			total_wait_time = cur_wait_time + cur_microgame_data.bonusTime
		timer.wait_time = total_wait_time
		timer.start()
	transitioning = false
#endregion

#region MICROGAME SIGNAL FUNCTIONS
func override_instructions(big:String = "..n",small:String = "..n",ref:Texture2D = null) -> void:
	var txt : Array = [big,small]
	for text_index in range(txt.size()):
		if txt[text_index] == "":
			txt[text_index] = "..n"
	
	ui_data = {
		"instructionsBig" : txt[0],
		"InstructionsSmall" : txt[1],
		"referenceImage" : ref,
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
		cur_microgame_pool_array = get_game_pool(cur_microgame_pool)
	
	cur_game_name = cur_microgame_pool_array[0]
	
	cur_game = resource_preloader.get_resource(cur_game_name).instantiate()
	
	cur_microgame_pool_array.erase(cur_game_name)

	print_debug("Current Microgame Pool: " + str(cur_microgame_pool_array))
	print_debug("Selected Microgame: " + cur_game_name)

	return cur_game

func get_microgame_data(force_game: String = "") -> void:
	cur_microgame = get_microgame(force_game)
	var local_game_data : MicrogameData = cur_microgame.microgame_data
	
	for i in cur_microgame_data:
		if ["instructionsSmall", "set_size"].has(i): continue

		cur_microgame_data[i] = local_game_data.get(i)
	
	cur_microgame_data.instructionsSmall = local_game_data.instructionSmall1 + "--" + local_game_data.instructionSmall2

	cur_microgame_data.Length = local_game_data.set_size.y
	cur_microgame_data.Width = local_game_data.set_size.x
	
	cur_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

func skip_game() -> void:
	if transitioning: return
	
	if cur_microgame.canSkip():
		timer.stop()
		cur_microgame.end_microgame.emit()
	else:
		ui_captcha_window._display_error_text(cur_microgame_data.errorMessage)

func checkbox_pressed() -> void:
	start_game()

func _on_captcha_animation_player_animation_finished(anim_name: StringName) -> void:
	if !["gametransition_end", 
	"gametransition_end_beginning", 
	"gametransition_speedup", 
	"gametransition_gameover", 
	"gametransition_speedup_beginning",
	"gametransition_boss"].has(anim_name): return

	if anim_name != "gametransition_gameover":
		on_transition_complete.emit()
	captcha_input_disabler.visible = false
