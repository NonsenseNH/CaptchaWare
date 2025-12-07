extends Microgame

const PHONE_CALL_WINDOW = preload("res://instances/PhoneVerification/phone_call_window.tscn")
@onready var phonenumber_label: Label = $phonenumber
var phone_number: int = 0

var real_number_calling : bool = false
var has_answered: bool = false
# Called when the node enters the scene tree for the first time.

var fake_number_type : PackedStringArray = [
	"ding",
	"erynn",
	"hira",
	"jackson",
	"jam",
	"juhin",
	"julnz",
	"marcz",
	"miel",
	"mystery",
	"nonsense",
	"puppet",
	"zac"
]

@onready var popup: AudioStreamPlayer = $popup

func _ready() -> void:
	phonenumber_label.text = generate_number()

	await get_tree().create_timer(randf_range(2.0, 4.0)).timeout

	pop_up_window()


func pop_up_window() -> void: #spawn window
	var phone_call_window : Control = PHONE_CALL_WINDOW.instantiate()
	var correct_one = bool(randi_range(0, 1))
	
	phone_call_window.call_answered.connect(on_call_answered)
	phone_call_window.call_declined.connect(on_call_declined)
	
	add_child(phone_call_window)

	set_camera_shake.emit(10, 0.5)
	popup.play()

	if correct_one:
		phone_call_window.phone_number_node.text = phonenumber_label.text
		real_number_calling = true
	else:
		phone_call_window.phone_number_node.text = generate_number()
		phone_call_window.phone_audio.stream = get_phone_call_audio()

func get_phone_call_audio() -> AudioStream:
	var path : String = "res://sounds/microgames/phone_verification/"

	if real_number_calling:
		path += "automated_message.mp3"
	else:
		path += "fake_numbers/" + fake_number_type[randi_range(0, fake_number_type.size() - 1)]
		var audio_phone_final : PackedStringArray = get_file_list(path, ".mp3")
		path += "/" + audio_phone_final[randi_range(0, audio_phone_final.size() - 1)]
	
	return load(path)

func generate_number() -> String:
	var number_text: String = ""
	phone_number = randi_range(9999999999, 1000000000)
	
	var number_array : PackedStringArray = str(phone_number).split()
	
	number_text = "+1 ("
	for i in range(10):
		number_text += number_array[i] + get_phone_format(i)
	return number_text

func get_phone_format(i: int) -> String:
	match i:
		2:
			return ") "
		5:
			return "-"
		_:
			return ""

func canSkip() -> bool:
	return false

func isWinning() -> bool:
	return has_answered && real_number_calling

func on_call_answered() -> void:
	has_answered = true

	await get_tree().create_timer(0.5).timeout

	force_end_mircogame()

func on_call_declined() -> void:
	if real_number_calling:
		await get_tree().create_timer(0.5).timeout
		force_end_mircogame()
		return
	
	await get_tree().create_timer(1.5).timeout

	pop_up_window()
	
