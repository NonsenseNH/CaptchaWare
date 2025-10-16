extends Microgame

const BUTTON_ANSWERS = preload("res://instances/howManyFingers/buttonAnswers.tscn")

@onready var hand: Sprite2D = $hand_group/hand
@onready var grid_container: GridContainer = $GridContainer
@onready var hand_anim: AnimationPlayer = $hand_group/hand/anim

var correct_fingers_array : Array[int] = []
var fingers_shown : int = 0
var how_many_should_answer : int = 0

var has_won : bool = false
var answered : int = 0

var buttons_pool : Array = []
signal disable_buttons(curButtonAnswer: int, correct : bool)
signal reveal_buttons

func _ready() -> void:
	match difficulty:
		3:
			how_many_should_answer = 2
			hand_anim.play("show fingers 2")
		4:
			how_many_should_answer = 3
			hand_anim.play("show fingers 3")
		_:
			how_many_should_answer = 1
			hand_anim.play("show fingers")
	
	for i in range(how_many_should_answer):
		correct_fingers_array.append(randi_range(1,5))
	generate_answers_n_buttons()

func generate_answers_n_buttons() -> void:
	var correct_fingers : int = correct_fingers_array[0]
	var correct_button : int = randi_range(0,3)
	var random_answers : Array = []
	
	for i in range(3):
		var cur_rand_num : int
		while true:
			cur_rand_num = randi_range(1,5)
			if (!random_answers.has(cur_rand_num) && cur_rand_num != correct_fingers): break
		random_answers.append(cur_rand_num)
	
	var rand_answers_index := 0
	
	for button in range(4):
		var button_instance := BUTTON_ANSWERS.instantiate()
		
		if button == correct_button:
			button_instance.cur_numbers = str(correct_fingers)
		else:
			button_instance.cur_numbers = str(random_answers[rand_answers_index])
			rand_answers_index += 1
		
		button_instance.button_answered.connect(answer_button_pressed)
		
		disable_buttons.connect(button_instance.disable_buttons)
		reveal_buttons.connect(button_instance.reaveal_numbers)
		
		grid_container.add_child(button_instance)
		buttons_pool.append(button_instance)

func regenerate_answers() -> void:
	var correct_fingers : int = correct_fingers_array[answered]
	var correct_button : int = randi_range(0,3)
	var random_answers : Array = []
	
	for i in range(3):
		var cur_rand_num : int
		while true:
			cur_rand_num = randi_range(1,5)
			if (!random_answers.has(cur_rand_num) && cur_rand_num != correct_fingers): break
		random_answers.append(cur_rand_num)
	
	var rand_answers_index := 0
	
	for button in range(4):
		var button_instance : Control = buttons_pool[button]
		
		if button == correct_button:
			button_instance.cur_numbers = str(correct_fingers)
		else:
			button_instance.cur_numbers = str(random_answers[rand_answers_index])
			rand_answers_index += 1
		
		button_instance.reaveal_numbers()

func answer_button_pressed(cur_button:Button) -> void:
	var is_correct = cur_button.text == str(correct_fingers_array[answered])
	
	answered += 1
	
	if !is_correct: 
		disable_buttons.emit(int(cur_button.text), is_correct)
		skip_timer.emit()
		return
	
	if answered != how_many_should_answer:
		regenerate_answers()
		return
	
	disable_buttons.emit(int(cur_button.text), is_correct)
	has_won = true
	skip_timer.emit()
	hand_anim.play("thumbs up")

func reveal_buttons_func() -> void:
	override_instruction_text.emit("fingers", "How many--Choose the answer from the box")
	reveal_buttons.emit()

func canSkip() -> bool:
	return answered

func isWinning() -> bool:
	super.isWinning()
	return has_won

func get_random_fingers() -> void:
	hand.texture = load("res://sprites/how_many_fingers/hands_" + str(correct_fingers_array[fingers_shown]) + ".png")
	fingers_shown += 1
