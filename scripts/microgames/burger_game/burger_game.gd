extends Microgame

const INGREDIENT_INSTANCE := preload("uid://ciwbi38tanbmb")

enum Ingredients {
	TOP_BUN,
	ONION,
	LETTUCE,
	TOMATO,
	CHEESE,
	BURGER,
	BOTTOM_BUN
}

const INGREDIENT_THICKNESS := [
	20,
	7,
	10,
	7,
	13,
	15,
	25
]

const INGREDIENT_STRING := [
	"BUN",
	"ONION",
	"LETTUCE",
	"TOMATO",
	"CHEESE",
	"PATTY"
]

const KEYBIND_ARRAY := [
	66, #B
	79, #O
	76, #L
	84,	#T
	67, #C
	80  #P
]

const DIFFICULTY_INGREDIENT_AMOUNT_RANGE := [
	[1, 1],
	[1, 2],
	[2, 3],
	[3, 4]
]

var used_ingredients := []

var cur_order_array := []
var cur_order_string : PackedStringArray = []

var cur_order : = 0

@onready var burger_pos: Marker2D = $burger_pos

@onready var button_grid: GridContainer = $'ingredients tab/ButtonGrid'

@onready var fail_text: Label = $'Fail text'

@onready var ingredients_list_text: RichTextLabel = $notepad/Label

var prev_ingredient: Ingredients = Ingredients.BOTTOM_BUN
var prev_ingredient_pos : Vector2 = Vector2.ZERO

var bottom_bun_placed: bool = false

var finished_burger : bool = false

var stop_game : bool = false

@onready var slap_ingredient_sound: AudioStreamPlayer = $sounds/SlapIngredientSound
@onready var ding_sound: AudioStreamPlayer = $sounds/DingSound
@onready var buzzer_sound: AudioStreamPlayer = $sounds/BuzzerSound

func _ready() -> void:
	set_random_order()

func set_random_order() -> void:
	cur_order_array = [Ingredients.BURGER]

	var available_ingredients := [Ingredients.ONION, Ingredients.LETTUCE, Ingredients.TOMATO, Ingredients.CHEESE]
	
	var range_set : Array = DIFFICULTY_INGREDIENT_AMOUNT_RANGE[difficulty - 1]
	for i in range(randi_range(range_set[0], range_set[1])):
		var cur_ingredient : int = available_ingredients.pick_random()

		cur_order_array.append(cur_ingredient)
		available_ingredients.erase(cur_ingredient)
	
	cur_order_array.append(Ingredients.TOP_BUN)

	var num := 1
	for i in cur_order_array:
		cur_order_string.append(str(num) + ". " +INGREDIENT_STRING[i])
		num += 1

	update_ingredients_list(true)

func update_ingredients_list(setting_up_text := false, cur_ingredient : Ingredients = Ingredients.BOTTOM_BUN) -> void:
	if !setting_up_text:
		var cur_string := cur_order_string[cur_order]

		if cur_order_array[cur_order] != cur_ingredient: #when you fail
			set_camera_shake.emit(5, .5)
			complete_microgame()

			buzzer_sound.play()
			
			fail_text.visible = true
			return
		
		cur_order_string.set(cur_order, "[color=00000075][s]" + cur_string + "[/s][/color]")
		cur_order += 1
	
	ingredients_list_text.text = ""
	for i in cur_order_string.size():
		ingredients_list_text.text += cur_order_string[i] + "[br]"

func _input(event: InputEvent) -> void:
	if stop_game || !(event is InputEventKey and event.pressed) || !KEYBIND_ARRAY.has(event.keycode): return

	var cur_ingred_index := KEYBIND_ARRAY.find(event.keycode)

	button_grid.get_child(cur_ingred_index)._on_button_pressed()
		
func stop_all_buttons() -> void:
	for child in button_grid.get_children():
		child.disabled()

func place_ingredient(ingredient_type: Ingredients) -> void:
	if used_ingredients.has(ingredient_type) : return

	var cur_ingredient := INGREDIENT_INSTANCE.instantiate()
	cur_ingredient.set_ingredient(ingredient_type)

	burger_pos.add_child(cur_ingredient)

	var set_pos : Vector2 = prev_ingredient_pos + (Vector2.UP * INGREDIENT_THICKNESS[prev_ingredient])
	cur_ingredient.position = set_pos + cur_ingredient.offset_set

	used_ingredients.append(ingredient_type)

	prev_ingredient_pos = cur_ingredient.position
	prev_ingredient = ingredient_type

	update_ingredients_list(false, ingredient_type)

	slap_ingredient_sound.play()

	if cur_order_array[cur_order - 1] != ingredient_type || ingredient_type != 0: return

	ding_sound.play()
	
	finished_burger = true
	complete_microgame()
	

func complete_microgame() -> void:
	stop_game = true
	skip_timer.emit()
	stop_all_buttons()

func canSkip() -> bool:
	return stop_game

func isWinning() -> bool:
	return finished_burger

func _on_ingredient_button_pressed(ingredient_type: int) -> void:
	place_ingredient(ingredient_type)
