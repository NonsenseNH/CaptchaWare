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

var prev_ingredient: Ingredients = Ingredients.BOTTOM_BUN
var prev_ingredient_pos : Vector2 = Vector2.ZERO

var bottom_bun_placed: bool = false

const INGREDIENT_THICKNESS := {
	Ingredients.TOP_BUN : 20,
	Ingredients.ONION : 10,
	Ingredients.LETTUCE : 10,
	Ingredients.TOMATO : 15,
	Ingredients.CHEESE : 10,
	Ingredients.BURGER : 25,
	Ingredients.BOTTOM_BUN : 20
}

func _input(event: InputEvent) -> void:
	if !(event is InputEventKey and event.pressed): return

	match event.keycode:
		KEY_B:
			if bottom_bun_placed:
				place_ingredient(Ingredients.TOP_BUN)
			else:
				place_ingredient(Ingredients.TOP_BUN)
				bottom_bun_placed = true
		KEY_O:
			place_ingredient(Ingredients.ONION)
		KEY_L:
			place_ingredient(Ingredients.LETTUCE)
		KEY_T:
			place_ingredient(Ingredients.TOMATO)
		KEY_C:
			place_ingredient(Ingredients.CHEESE)
		KEY_P:
			place_ingredient(Ingredients.BURGER)
		

func place_ingredient(ingredient_type: Ingredients) -> void:
	var cur_ingredient := INGREDIENT_INSTANCE.instantiate()
	cur_ingredient.set_ingredient(ingredient_type)

	if ingredient_type != Ingredients.BOTTOM_BUN:
		cur_ingredient.position = prev_ingredient_pos + (Vector2.UP * INGREDIENT_THICKNESS[prev_ingredient])

	prev_ingredient_pos = cur_ingredient.position
	prev_ingredient = ingredient_type

