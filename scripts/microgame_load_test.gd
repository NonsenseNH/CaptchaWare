extends Node2D

const JSON_FILE_LOCATION : String = "res://scripts/microgames/microgames.json"

@export var force_microgame : String = ""

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

var cur_microgame : Node = null

var cur_microgame_pool_array : Array = []

var microgame_json : Dictionary = {}
var cur_microgame_data : Dictionary = {}

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
	
	microgame_json = JSON.parse_string(FileAccess.open(JSON_FILE_LOCATION, FileAccess.READ).get_as_text())
	
	get_microgame_data(force_microgame)
	set_up_window_size()
	change_game()

func camera_shake(intensity : float, duration : float) -> void:
	camera.shake_camera(intensity, duration)

func get_microgame_data(force_game: String = "") -> void:
	cur_microgame = get_microgame(force_game)
	
	if cur_microgame == null: return
	
	cur_microgame_data = microgame_json.microgames[cur_microgame.name]
	cur_window_size = Vector2(cur_microgame_data.Width, cur_microgame_data.Length)

func set_up_window_size(tween_window: bool = false) -> void:
	if cur_microgame == null: return
	ui_captcha_window.set_up_ui_data({
		"windowSize" : Vector2(cur_microgame_data.Width, cur_microgame_data.Length),
		"windowTween" : tween_window,
		"tweenSpeed" :  0,
	})

func change_game():
	if cur_microgame == null: return
	cur_microgame.z_index += 1
	
	override_instructions(cur_microgame_data.instructionsBig, cur_microgame_data.InstructionsSmall, cur_microgame_data.referenceImage)
	
	on_transition_complete.connect(cur_microgame.on_transition_complete)
	cur_microgame.override_instruction_text.connect(override_instructions)
	cur_microgame.set_camera_shake.connect(camera_shake)
	
	ui_captcha_window.cur_game.add_child(cur_microgame)
	
	cur_microgame.global_position = ui_captcha_window.cur_game.global_position

	on_transition_complete.emit()

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_text_submit") && !verify_button.disabled:
			skip_game()

func skip_game() -> void:
	if cur_microgame == null: return
	if cur_microgame.canSkip():
		print_debug("CanSkipGame")
	else:
		ui_captcha_window._display_error_text(microgame_json.microgames[cur_microgame.name].errorMessage)

func get_microgame(force_game : String) -> Node:
	var cur_game : Node
	
	if force_microgame == "": return null
	cur_game = load("res://microgames/" + force_game + ".tscn").instantiate()
	return cur_game
