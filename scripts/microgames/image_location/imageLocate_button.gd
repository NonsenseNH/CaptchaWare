extends Button

@onready var check: Sprite2D = $check
@onready var sprite_2d: Sprite2D = $Sprite2D
var cur_frame: int = 0
var cur_size: float = 0.155
var selection_type : int = 0 # 0 = no, 1 = mandatory, 2 = optional

signal gainPoints(yes:int)
signal count_selected(a:int)

func _ready() -> void:
	sprite_2d.texture = get_parent().cur_image
	sprite_2d.frame = cur_frame

func _on_toggled(toggled_on: bool) -> void:
	cur_size = (0.13 if toggled_on else 0.155)
	var shrinkAnim := create_tween()
	shrinkAnim.tween_property(sprite_2d, "scale", Vector2.ONE * cur_size, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	var add_point : int = 0
	
	if (toggled_on && [1, 2].has(selection_type)) || (selection_type == 0 && !toggled_on):
		if selection_type == 2:
			add_point = 0
		else:
			add_point = 1
	else:
		if selection_type != 2:
			add_point = -1
	
	gainPoints.emit(add_point)
	count_selected.emit(1 if toggled_on else -1)
	
	check.visible = toggled_on
	pass # Replace with function body.
