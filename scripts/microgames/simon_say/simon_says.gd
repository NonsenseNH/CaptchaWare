extends Microgame

const DIFFICULTY_ARRAY = [
	{
		"speed" : .5,
		"amount" : 3
	},
	{
		"speed" : .45,
		"amount" : 4
	},
	{
		"speed" : .4,
		"amount" : 5
	},
	{
		"speed" : .3,
		"amount" : 6
	},
]

const RED = 0
const BLUE = 2
const YELLOW = 1
const GREEN = 3

const SEQUENCE_COLOR = "b1b1b1"

var simon_says_sequence : PackedInt32Array = []

var how_many_presses := 3
var cur_button_index := 0

@onready var buttons: GridContainer = $buttons

var finished_game := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	how_many_presses = DIFFICULTY_ARRAY[difficulty - 1].amount

	for i in range(how_many_presses):
		var value := randi_range(0, 3)
		simon_says_sequence.append(value)

	await get_tree().create_timer(.5).timeout

	start_simon_says_sequence()

func start_simon_says_sequence() -> void:
	var cur_speed : float = DIFFICULTY_ARRAY[difficulty - 1].speed
	
	for i in range(how_many_presses):
		press_buttons_simon(simon_says_sequence[i])

		await get_tree().create_timer(cur_speed).timeout
	
	activate_buttons()

func activate_buttons() -> void:
	for button in buttons.get_children():
		var the_button := button.get_child(0)

		the_button.disabled = false
		the_button.self_modulate = Color.WHITE

func press_buttons_simon(button_index : int) -> void:
	var cur_button := buttons.get_child(button_index).get_child(0)

	cur_button.self_modulate = Color.WHITE

	await get_tree().create_timer(.15).timeout

	cur_button.self_modulate = Color(SEQUENCE_COLOR)

func button_check(button_index : int) -> void:
	if cur_button_index >= how_many_presses: return
	
	if simon_says_sequence[cur_button_index] != button_index:
		results(true)
		return
	
	if (how_many_presses - 1) > cur_button_index:
		cur_button_index += 1
	else:
		results()

func results(failed := false) -> void:
	if failed:
		set_camera_shake.emit(5, .5)
		color_each_button(Color("ea2840"))
	else:
		color_each_button(Color("00df41"))
	skip_timer.emit()
	finished_game = true

func color_each_button(the_color_in_question : Color) -> void:
	for button in buttons.get_children():
		var the_button := button.get_child(0)
		the_button.disabled = true
		
		var flash_tween := create_tween()
		var brighter_color := the_color_in_question
		brighter_color.v += .6
		flash_tween.tween_property(the_button, "modulate", the_color_in_question, .5).from(brighter_color).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _on_green_pressed() -> void:
	button_check(GREEN)

func _on_blue_pressed() -> void:
	button_check(BLUE)

func _on_yellow_pressed() -> void:
	button_check(YELLOW)

func _on_red_pressed() -> void:
	button_check(RED)

func isWinning() -> bool:
	return finished_game && how_many_presses <= cur_button_index

func canSkip() -> bool:
	return finished_game
