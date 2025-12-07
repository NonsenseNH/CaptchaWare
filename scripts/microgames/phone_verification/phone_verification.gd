extends Microgame

@onready var phonenumber_label: Label = $phonenumber
var phone_number: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	phonenumber_label.text = generate_number()

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
	return super.isWinning()
