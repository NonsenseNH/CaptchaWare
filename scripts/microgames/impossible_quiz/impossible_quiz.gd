extends Microgame

const QUESTION_SPRITES_DIR = "res://sprites/impossible_quiz/questions/"

const DIFFICULTY_QUESTIONS_AMOUNT = [3, 4, 5, 5]

@onready var questions: TextureRect = $questions
@onready var question_number: Sprite2D = $QuestionNumber

@onready var ding_sound: AudioStreamPlayer = $sounds/ding
@onready var fail_sound: AudioStreamPlayer = $sounds/fail
@onready var win_sound: AudioStreamPlayer = $sounds/win
@onready var gameover_sound: AudioStreamPlayer = $sounds/gameover

@onready var lives_number_anim: AnimationPlayer = $LivesNumberAnim

var question_array : PackedStringArray = []

var total_questions := 3
var cur_question := 0

var correct_answer_index := 3

var lives := 2

var can_answer := true
var won := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_questions = DIFFICULTY_QUESTIONS_AMOUNT[difficulty - 1]
	
	var all_question_png_files : Array = get_file_list(QUESTION_SPRITES_DIR)

	for i in range(total_questions):
		var png_file : String = all_question_png_files.pick_random()

		question_array.append(png_file)

		all_question_png_files.erase(png_file)
	
	change_question()
	
func change_question() -> void:
	if cur_question >= total_questions:
		win_sound.play()
		won = true
		lives_number_anim.play("win")

		skip_timer.emit()
		return
	
	var png_split_file := question_array[cur_question].split("--", false)

	correct_answer_index = int(png_split_file[1])

	question_number.frame = cur_question
	questions.texture = load(QUESTION_SPRITES_DIR + question_array[cur_question])

func _on_button4_pressed() -> void:
	answer_check(4)

func _on_button3_pressed() -> void:
	answer_check(3)

func _on_button2_pressed() -> void:
	answer_check(2)

func _on_button_pressed() -> void:
	answer_check(1)

func answer_check(button : int) -> void:
	if !can_answer: return

	if button == correct_answer_index: 
		ding_sound.play()
		cur_question += 1
		change_question()
		return
	
	lives -= 1
	if lives <= 0:
		gameover_sound.play()
		lives_number_anim.play("gameover")

		skip_timer.emit()
	else:
		fail_sound.play()
		lives_number_anim.play("- 1 life")

	set_camera_shake.emit(5, 0.7)

	can_answer = false

	await get_tree().create_timer(2).timeout

	can_answer = true

func canSkip() -> bool:
	return won || lives <= 0

func isWinning() -> bool:
	return won

	
	
