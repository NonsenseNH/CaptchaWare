extends Microgame

@onready var phonenumber_label: Label = $phonenumber
var phone_number: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_number()

func generate_number() -> void:
	phone_number = randi_range(9999999999, 1000000000)
	
	var number_array : PackedStringArray = str(phone_number).split()
	
	phonenumber_label.text = "+1 ("
	for i in range(10):
		phonenumber_label.text += number_array[i] + get_phone_format(i)

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
