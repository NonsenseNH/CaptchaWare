extends Control

@onready var button: Button = $Button
@onready var button_grid: GridContainer = $'..'
@onready var cur_button_value := button_grid.get_children().find(self)

signal ingredient_button_pressed(ingredient_type : int)

func _on_button_pressed() -> void:
	ingredient_button_pressed.emit(cur_button_value)
	disabled()

func disabled() -> void:
	button.disabled = true
	modulate = Color("ffffff5f")