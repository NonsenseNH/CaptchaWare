extends Camera2D

class_name cam_effects

@export var parallax_offset_amount : float = 0
@export var shake_amount : float = 0

var shake_vector : Vector2 = Vector2.ZERO
var parallax_offset := Vector2.ZERO
@onready var default_zoom :Vector2 = zoom

var force_pause : bool = false

#region Effects
func pause_game(paused : bool) -> void: #use this function to prevent hitstop from unpausing the tree
	force_pause = paused
	get_tree().paused = paused

func shake_camera(intensity:float, duration:float = 0) -> void:
	if duration == 0:
		shake_amount = intensity
		return
	var shake_amount_tween : Tween = create_tween()
	shake_amount_tween.tween_property(self, "shake_amount", 0, duration).from(shake_amount + intensity).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func camera_bop_in(zoom_amount: float, duration:float) -> void:
	var bop_tween : Tween = create_tween()
	bop_tween.tween_property(self, "zoom", default_zoom, duration).from(Vector2.ONE * zoom_amount).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func camera_shake_process() -> void:
	if shake_amount == 0: return
	var final_amount : float = shake_amount
	shake_vector = Vector2(randf_range(-final_amount,final_amount), randf_range(-final_amount,final_amount))

func parallax_system() -> void:
	if parallax_offset_amount == 0: return
	parallax_offset = lerp(Vector2.ZERO, get_local_mouse_position(), parallax_offset_amount / 100.0)

func hit_stop(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = force_pause
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		parallax_system()

func _physics_process(_delta: float) -> void:
	camera_shake_process()

func _process(_delta: float) -> void:
	offset = shake_vector + parallax_offset
