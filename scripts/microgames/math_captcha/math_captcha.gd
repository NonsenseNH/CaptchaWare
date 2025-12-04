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
	var equation_array : Array = generate_equation()
	
	cur_text_problem = str(equation_array[0]) + " " + equation_array[2] + " " + str(equation_array[1])
	answer = equation_array[3]

func generate_equation() -> Array:
	var first_num : int = randi_range(0, 7)
	var second_num : int = randi_range(0, 7)
	var cur_math_signs : String = ["+", "-"].pick_random()
	var set_answer : int = 0
	
	if cur_math_signs == "-":
		while first_num - second_num == 0:
			first_num = randi_range(0, 7)
			second_num = randi_range(0, 7)
		set_answer = first_num - second_num
	else:
		set_answer = first_num + second_num
	
	return [first_num, second_num, cur_math_signs, set_answer]

func isWinning() -> bool:
	super.isWinning()
	return answer == int(line_edit.text)

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	if is_intro: return
	set_camera_shake.emit(3, 0.25)
