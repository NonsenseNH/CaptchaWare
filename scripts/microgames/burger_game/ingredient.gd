extends Sprite2D

const INGREDIENT_TYPES := {
	0: ["top_bun", Vector2(0, -20)],
	1: ["onion", Vector2(0, 0)],
	2: ["lettuce", Vector2(0, 0)],
	3: ["tomato", Vector2(0, 0)],
	4: ["cheese", Vector2(0, 5)],
	5: ["burger", Vector2(0, 0)],
	6: ["bottom_bun", Vector2(0, 0)]
}

var offset_set : Vector2 = Vector2.ZERO

func set_ingredient(ingredient_type: int) -> void:
	texture = load("res://sprites/burger_game/" + INGREDIENT_TYPES[ingredient_type][0] + ".png")
	offset_set = INGREDIENT_TYPES[ingredient_type][1]
