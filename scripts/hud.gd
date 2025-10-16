extends Control

const INSTRUCTIONS_FILE_PATH := "res://scripts/instructions/"

@export var testing : bool = false
@export var main_code : Node2D
@export var timer_node: Timer
@export var instructions: Label
@export var big_text: Label
@export var big_image: TextureRect
@export var reference_image: TextureRect
@export var error_label : Label
@export var captcha_window : TextureRect

@onready var cur_game: ColorRect = $captcha_window/curGame
@onready var progress_bar: ProgressBar = $captcha_window/blueBorder/instructions/ProgressBar
var time_ui : float = 0.0

var prev_window_size : Vector2

func set_up_ui_data(data:Dictionary) -> void:
	if (data.has("instructionsBig") && data.has("InstructionsSmall") && data.has("referenceImage")):
		_set_instructions(data.instructionsBig,data.InstructionsSmall,data.referenceImage)
	
	if (data.has("windowSize")):
		set_captcha_window_size(data.windowSize, data.windowTween, data.tweenSpeed)

func _set_instructions(text_override_big: String = "..n", text_override_small: String = "..n", ref_image : String = "..n") -> void:
	var instructions_2nd : Label = instructions.get_node("instructions2")
	
	if big_image.texture != null: big_image.texture = null
	
	reference_image.visible = false
	
	if reference_image.texture != null: 
		reference_image.texture = null
	
	if ref_image != "..n":
		reference_image.texture = load(ref_image)
		reference_image.visible = true
	
	if text_override_small != "..n":
		if text_override_small.contains("--"):
			var small_txt_array : PackedStringArray = text_override_small.split("--")
			instructions.text = small_txt_array[0]
			instructions_2nd.text = small_txt_array[1]
		else:
			instructions.text = text_override_small
	
	if text_override_big != "..n":
		if text_override_big.contains(".png"):
			big_text.text = ""
			big_image.texture = load(text_override_big)
		else:
			big_text.text = text_override_big

func _display_error_text(errortxt:String = "", reset_error : bool = false) -> void:
	var error_displayed : bool = error_label.visible
	
	if reset_error && error_displayed: 
		set_captcha_window_size(captcha_window.size + (Vector2.UP * 25), false)
		error_label.visible = false
		return
	
	if !error_displayed && errortxt != "":
		set_captcha_window_size(captcha_window.size + (Vector2.DOWN * 25), false)
		error_label.visible = true
		error_label.text = errortxt

func set_captcha_window_size(set_window_size : Vector2 = Vector2.ZERO,do_tween : bool = true, anim_speed : float = 1.0) -> void:
	#this is for centering the thing cuz the anchor is being stupid
	
	prev_window_size = captcha_window.size
	var captcha_pos_math_y : float = 0 
	var captcha_pos_math_x : float = 0 
	
	captcha_pos_math_y = calculate_center_offset(prev_window_size.y, set_window_size.y, captcha_window.position.y)
	captcha_pos_math_x = calculate_center_offset(prev_window_size.x, set_window_size.x, captcha_window.position.x)
	
	var captcha_size_pos_offset : Vector2 = Vector2(captcha_pos_math_x, captcha_pos_math_y)
	
	if do_tween:
		var captcha_size_tween : Tween = create_tween()
		var captcha_pos_tween : Tween = create_tween()
		
		captcha_size_tween.tween_property(captcha_window, "size", set_window_size, 0.5 / anim_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		captcha_pos_tween.tween_property(captcha_window, "position", captcha_size_pos_offset, 0.5 / anim_speed).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		
	else:
		captcha_window.size = set_window_size
		captcha_window.position = captcha_size_pos_offset

func calculate_center_offset(a:float,b:float,c:float) -> float:
	return (((a - b) / 2.0) + c)

func _process(_delta: float) -> void:
	if testing: return
	time_ui = lerpf(0, 100, timer_node.time_left / main_code.total_wait_time)
	progress_bar.value = lerpf(progress_bar.value, time_ui, minf(_delta * 20, 1))

func _on_verify_button_pressed() -> void:
	main_code.skip_game()
