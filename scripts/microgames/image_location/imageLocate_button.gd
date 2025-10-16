extends Button

@onready var check: Sprite2D = $check
@onready var sprite_2d: Sprite2D = $Sprite2D
var cur_frame: int = 0
var cur_size: float = 0.155
var correct_selection := false

signal gainPoints(yes:int)
signal count_selected(a:int)

func _ready() -> void:
	sprite_2d.texture = get_parent().cur_image
	sprite_2d.frame = cur_frame

func _on_toggled(toggled_on: bool) -> void:
	cur_size = (0.13 if toggled_on else 0.155)
	var shrinkAnim := create_tween()
	shrinkAnim.tween_property(sprite_2d, "scale", Vector2.ONE * cur_size, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	var add_point := 1 if (toggled_on && correct_selection || (!correct_selection && !toggled_on)) else -1
	
	gainPoints.emit(add_point)
	count_selected.emit(1 if toggled_on else -1)
	
	check.visible = toggled_on
	pass # Replace with function body.
