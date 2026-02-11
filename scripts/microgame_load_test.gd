extends Node2D

const JSON_FILE_LOCATION : String = "res://scripts/microgames/microgames.json"

@export var force_microgame : String = ""
@export_range(1, 4, 1) var cur_difficulty_test : int = 0 

@onready var bg: TextureRect = $bg

@onready var resource_preloader: ResourcePreloader = $ResourcePreloader

@onready var timer: Timer = $Timer
@onready var cur_wait_time := timer.wait_time
@onready var total_wait_time := cur_wait_time
@onready var og_wait_time := cur_wait_time

@onready var captcha_window: TextureRect = $window/captcha_window

@onready var captcha_bg: TextureRect = $bg

@onready var camera: Camera2D = $camera
@onready var intermission_text: Control = $window/intermissionText/judgement
@onready var ui_captcha_window: Control = $window
@onready var sounds: Node = $sounds

@onready var verify_button: Button = $window/captcha_window/lowbar/verifyButton

@onready var cur_game: ColorRect = $window/captcha_window/curGame
@onready var music: AudioStreamPlayer = $"../Mosik"

var cur_microgame : Node = null

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

var cur_window_size : Vector2 = Vector2.ZERO

var ui_data : Dictionary = {
	"instructionsBig" : "",
	"InstructionsSmall" : "",
	"referenceImage" : "",
	
	"windowSize" : Vector2.ZERO,
	"windowTween" : false,
	"tweenSpeed" : 1
}

signal on_transition_complete

func _ready() -> void:
	var bus_index = AudioServer.get_bus_index("Microgame Sounds")
	AudioServer.set_bus_volume_db(bus_index, 0)
	
	get_microgame_data(force_microgame)
	set_up_window_size()
	change_game()

func camera_shake(intensity : float, duration : float) -> void:
	camera.shake_camera(intensity, duration)

func get_microgame_data(force_game: String = "") -> void:
	if force_game == "":
		cur_microgame = cur_game.get_child(0)
	else:
		cur_microgame = get_microgame(force_game)
	
	var local_game_data : MicrogameData = cur_microgame.microgame_data
	
	for i in cur_microgame_data:
		if ["instructionsSmall", "set_size"].has(i): continue

		cur_microgame_data[i] = local_game_data.get(i)
	
	cur_microgame_data.instructionsSmall = local_game_data.instructionSmall1 + "--" + local_game_data.instructionSmall2

	cur_microgame_data.Length = local_game_data.set_size.y
	cur_microgame_data.Width = local_game_data.set_size.x
	
	cur_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

	print_debug(cur_microgame_data.keys())

func set_up_window_size(tween_window: bool = false) -> void:
	if cur_microgame == null: return
	ui_captcha_window.set_up_ui_data({
		"windowSize" : Vector2(cur_microgame_data.Width, cur_microgame_data.Length),
		"windowTween" : tween_window,
		"tweenSpeed" :  0,
	})

func freeze_timer() -> void:
	timer.paused = true

func change_game():
	if cur_microgame == null: return
	cur_microgame.z_index += 1
	
	override_instructions(cur_microgame_data.instructionsBig, cur_microgame_data.instructionsSmall, cur_microgame_data.referenceImage)
	
	on_transition_complete.connect(cur_microgame.on_transition_complete)
	cur_microgame.override_instruction_text.connect(override_instructions)
	cur_microgame.set_camera_shake.connect(camera_shake)
	cur_microgame.skip_timer.connect(skip_timer)
	cur_microgame.end_microgame.connect(results)
	cur_microgame.freeze_timer_signal.connect(freeze_timer)
	cur_microgame.difficulty = cur_difficulty_test
	
	if force_microgame != "":
		ui_captcha_window.cur_game.add_child(cur_microgame)
	
	cur_microgame.global_position = ui_captcha_window.cur_game.global_position

	on_transition_complete.emit()

	if  !cur_microgame_data.noTimer:
		if cur_microgame_data.has("staticTimer") && cur_microgame_data.staticTimer:
			total_wait_time = og_wait_time + cur_microgame_data.bonusTime
		else:
			total_wait_time = cur_wait_time + cur_microgame_data.bonusTime
		timer.wait_time = total_wait_time
		timer.start()

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_text_submit") && !verify_button.disabled:
			skip_game()

func skip_game() -> void:
	if cur_microgame == null: return
	if cur_microgame.canSkip():
		timer.stop()

		cur_microgame.end_microgame.emit()
	else:
		ui_captcha_window._display_error_text(cur_microgame_data.errorMessage)

func skip_timer() -> void:
	var skip_time_to : int = 1
	
	if timer.time_left < skip_time_to: return
	timer.wait_time = skip_time_to
	timer.start()

func get_microgame(force_game : String) -> Node:
	var cur_game : Node
	
	if force_microgame == "": return null
	cur_game = load("res://microgames/" + force_game + ".tscn").instantiate()
	return cur_game


func _on_timer_timeout() -> void:
	cur_microgame.end_microgame.emit()

func results() -> void:
	if cur_microgame == null || cur_microgame.skipped: return

	cur_microgame.skipped = true

	if cur_microgame.isWinning():
		print_debug("has won")
	else:
		print_debug("has lost")

func _on_verify_button_pressed() -> void:
	skip_game()
