extends Microgame

@onready var line_edit: LineEdit = $LineEdit

var cur_text_problem : String = ""
var answer : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_edit.grab_focus.call_deferred()
	generate_math_eq()
	override_instruction_text.emit(cur_text_problem)
	pass # Replace with function body.

func generate_math_eq() -> void:
	var cur_math_signs : String = ["plus", "minus"].pick_random()
	var first_num : int = randi_range(0, 7)
	var second_num : int = randi_range(0, 7)
	
	match cur_math_signs:
		"plus":
			cur_text_problem = str(first_num) + "+" + str(second_num)
			answer = first_num + second_num
		"minus":
			if first_num < second_num:
				second_num = first_num
			cur_text_problem = str(first_num) + "-" + str(second_num)
			answer = first_num - second_num

func isWinning() -> bool:
	super.isWinning()
	return answer == int(line_edit.text)

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	set_camera_shake.emit(3, 0.25)
