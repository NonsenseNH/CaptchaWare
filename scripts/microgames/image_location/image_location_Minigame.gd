extends Microgame

@export var cur_image: Texture2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const IMAGE_LOCATE_BUTTON = preload("uid://f17y4s6cfnf4")
const FILE_PATH: String = "res://sprites/locate_images/"

var min_points := 0
var points := 0
var selected := 0

var cur_object := ""

func _on_ready() -> void:
	set_image()

func set_image() -> void:
	var image_array : Array = get_file_list(FILE_PATH)
	var difficulty_2_images := ["1.png","8.png","10.png","11.png","waldo.png"]
	
	var cur_image_value : String
	
	while true:
		cur_image_value = image_array.pick_random()
		if (difficulty >= 2 || !difficulty_2_images.has(cur_image_value)): break
	
	#debug code
	#cur_image_value = "11.png"
	
	if cur_image == null:
		cur_image = load(FILE_PATH + cur_image_value)
	
	var correct_answers_file := FileAccess.open(FILE_PATH + cur_image_value.replace(".png", ".txt"), FileAccess.READ)
	
	var correct_answers : PackedStringArray = []
	var line : String = correct_answers_file.get_as_text()
	
	correct_answers = line.split(",", false)
	
	cur_object = correct_answers[16].strip_edges()
	override_instruction_text.emit(cur_object)

	for button in range(16):
		var button_node : Button = IMAGE_LOCATE_BUTTON.instantiate()
		var button_type : int = int(correct_answers[button].strip_edges())
		button_node.cur_frame = (button)
	
		if ([1, 2].has(button_type)):
			button_node.selection_type = button_type
			if button_type == 1:
				min_points += 1
		
		#print_debug(button)
		add_child(button_node)
		
		button_node.gainPoints.connect(pointManager)
		button_node.count_selected.connect(count_selected)

func isWinning() -> bool:
	super.isWinning()
	return points >= min_points

func canSkip() -> bool:
	return selected >= mini(min_points,3)

func pointManager(add:int) -> void:
	points += add
	#print_debug(points)

func count_selected(point:int = 0) -> void:
	audio_stream_player.play()
	selected += point
