extends Camera2D

class_name cam_effects

@export var parallax_offset_amount : float = 0

var shake_amount : float = 0
var shake_vector : Vector2 = Vector2.ZERO

func shake_camera(intensity:float, duration:float) -> void:
	if duration == 0:
		shake_amount = intensity
	var shake_amount_tween : Tween = create_tween()
	shake_amount_tween.tween_property(self, "shake_amount", 0, duration).from(shake_amount + intensity).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func camera_shake_process() -> void:
	if shake_amount == 0: return
	shake_vector = Vector2(randf_range(-shake_amount,shake_amount), randf_range(-shake_amount,shake_amount))
	offset += shake_vector

func _process(_delta: float) -> void:
	offset = lerp(Vector2.ZERO, get_local_mouse_position(), parallax_offset_amount / 100.0)
	camera_shake_process()
