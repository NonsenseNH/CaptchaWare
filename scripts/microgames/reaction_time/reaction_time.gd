extends Microgame

const BLUE_COLOR := Color("2b87d1")
const RED_COLOR := Color("ce2636")
const GREEN_COLOR := Color("4bdb6a")

@onready var reaction_timer: Timer = $reactionTimer
@onready var reaction_time_button: Button = $reactionTimeButton

@onready var anim: AnimationPlayer = $cowboy/anim
@onready var cowboy: Control = $cowboy
@onready var result_text: Label = $cowboy/result

@onready var ticking_sound: AudioStreamPlayer = $ticking
@onready var ding_sound: AudioStreamPlayer = $ding

var test_is_active := false
var click_now := false
var test_done := false

var reaction_time_start_time := 0.0

var difficulty_window = [1, .8, .6, .4]

var minimum_time := 0.0

var success := false
var done := false

func _ready() -> void:
	minimum_time = difficulty_window[difficulty - 1]

func _process(delta: float) -> void:
	if !click_now: return

	reaction_time_start_time += delta

	if reaction_time_start_time > minimum_time:
		finish_test()

func _on_reaction_time_button_pressed() -> void:
	if test_done: return

	if test_is_active:
		finish_test()
	else:
		ticking_sound.play()
		set_button_color(RED_COLOR)

		reaction_timer.wait_time = randf_range(1.0, 2.0)
		reaction_timer.start()
	
	test_is_active = !test_is_active

func finish_test() -> void:
	ticking_sound.stop()
	ding_sound.stop()

	test_done = true

	reaction_timer.stop()

	result()

	click_now = false

func result() -> void:
	cowboy.visible = true

	set_camera_shake.emit(10, 0.5)

	if reaction_time_start_time <= minimum_time && click_now:
		anim.play("win")
		success = true
		done = true
		result_text.text = "Nice Shot!"
	else:
		done = true
		anim.play("lose")
		if reaction_time_start_time > minimum_time:
			result_text.text = "Too Late!"
		else:
			result_text.text = "Too Early!"

func set_button_color(color: Color) -> void:
	for i in reaction_time_button.get_children():
		i.visible = false
	
	var colors_array := [BLUE_COLOR, RED_COLOR, GREEN_COLOR]
	
	reaction_time_button.get_child(colors_array.find(color)).visible = true
	
	reaction_time_button.self_modulate = color

func _on_reaction_timer_timeout() -> void:
	set_button_color(GREEN_COLOR)
	ding_sound.play()
	ticking_sound.stop()

	click_now = true

func isWinning() -> bool:
	return success

func canSkip() -> bool:
	return done

func _on_anim_animation_finished(_anim_name: StringName) -> void:
	skip_timer.emit()
