extends Button

@onready var check: Sprite2D = $check
@onready var sprite_2d: Sprite2D = $Sprite2D
var cur_image : String = ""
var correct_option : bool = false
var cur_image_size : float = 0.087

signal gainPoints(yes:int)
signal count_selected(a:int)

func _ready() -> void:
	sprite_2d.texture = load("res://sprites/images_with/images/" + cur_image + ".png")

func _on_toggled(toggled_on: bool) -> void:
	cur_image_size = (0.075 if toggled_on else 0.087)
	
	var shrinkAnim := create_tween()
	shrinkAnim.tween_property(sprite_2d, "scale", Vector2.ONE * cur_image_size, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	var add_point := 1 if (toggled_on && correct_option || (!correct_option && !toggled_on)) else -1
	gainPoints.emit(add_point)
	
	count_selected.emit(1 if toggled_on else -1)
	
	check.visible = toggled_on
	pass # Replace with function body.
