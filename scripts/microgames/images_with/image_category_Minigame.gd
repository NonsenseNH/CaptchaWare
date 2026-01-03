extends Microgame

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const BUTTON = preload("uid://cvj5co1i86i5s")
const IMAGE_DIRECTORY : String = "res://sprites/images_with/"
var image_data: Dictionary = {}
var cur_object:String = ""
var prev_image_number : int = 0

var images_name_pool : Array = []

var cur_selected := 0

var points : int = 0
var required_points : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_json_data()
	load_buttons()

func load_buttons() -> void:
	var cur_image : Texture2D = load("res://sprites/images_with/images/1_" + cur_object + ".png")
	override_instruction_text.emit(cur_object.replace("_"," "), "", cur_image)
	
	var cur_categ_button : Array[String] = get_categories(3)
	
	for category in cur_categ_button:
		var button : Button = BUTTON.instantiate()
		
		button.cur_image = get_unique_image(category)
		
		if (category == cur_object):
			button.correct_option = true
			required_points += 1
		
		button.gainPoints.connect(gain_points)
		button.count_selected.connect(count_selected)
		
		add_child(button)

func get_unique_image(category : String) -> String:
	var cur_image_name : String = ""
	
	while true:
		var cur_index : int = get_number(image_data.category[category].range)
		cur_image_name = str(cur_index) + "_" + category
		
		if !images_name_pool.has(cur_image_name): break 
	
	images_name_pool.append(cur_image_name)
	
	return cur_image_name

func get_number(category_range : Array) -> int:
	var cur_num : int = 1
	
	cur_num = randi_range(category_range[0],category_range[1])
	
	return cur_num

func get_categories(amount_categories : int) -> Array[String]:
	var category_list : Array[String]
	
	for i in range(amount_categories):
		if !category_list.has(cur_object):
			category_list.append_array([cur_object,cur_object,cur_object])
			continue
		
		var category : String
		
		while (true):
			category = image_data.category.keys().pick_random()
			
			if !category_list.has(category):  break
		
		category_list.append_array([category,category,category])
	category_list.shuffle()
	return category_list

func _load_json_data() -> void:
	image_data = get_json_data(IMAGE_DIRECTORY + "imageTypes")
	cur_object = image_data.category.keys().pick_random()

func gain_points(yes:int) -> void:
	points += yes

func count_selected(a:int) -> void:
	audio_stream_player.play()
	cur_selected += a

func isWinning() -> bool:
	super.isWinning()
	return required_points == points

func canSkip() -> bool:
	return cur_selected >= mini(required_points,1)
