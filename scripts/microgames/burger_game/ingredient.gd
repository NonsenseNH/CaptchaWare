extends Sprite2D

const INGREDIENT_TYPES := {
	0: "top_bun",
	1: "onion",
	2: "lettuce",
	3: "tomato",
	4: "cheese",
	5: "burger",
	6: "bottom_bun"
}

func set_ingredient(ingredient_type: int) -> void:
	texture = load("res://sprites/burger_game/" + INGREDIENT_TYPES[ingredient_type] + ".png")
