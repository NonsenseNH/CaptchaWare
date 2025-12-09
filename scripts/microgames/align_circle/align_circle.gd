extends Microgame

@onready var circle_1_sprite: Sprite2D = $circle1
@onready var circle_2_sprite: Sprite2D = $circle2

@onready var text_slider: Label = $slider/text

@onready var slide_in_sound: AudioStreamPlayer = $slideIn
@onready var sliding_sound: AudioStreamPlayer = $sliding

@onready var slider: HSlider = $slider
var value_velocity : float = 0.0
var prev_value_slider : float = 0.0

var inserted : bool = false

var rotation_range : Array[float] = [0.0, 0.0] 
const ROTATION_THRESHHOLD = 7.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_circles()

func set_up_circles() -> void:
	var texture_rect1 := circle_1_sprite.get_child(0)
	var texture_rect2 := circle_2_sprite.get_child(0)
	
	const FILE_PATH = "res://sprites/align_circle/images/"

	var image_file_path : String = FILE_PATH + get_file_list(FILE_PATH, ".png").pick_random()

	texture_rect1.texture = load(image_file_path)
	texture_rect2.texture = load(image_file_path)

	var rand_rotation : float = 0.0

	while abs(rand_rotation) < 15.0:
		rand_rotation = randf_range(-90.0, 90.0)
	
	circle_1_sprite.rotation_degrees = rand_rotation
	rotation_range = [rand_rotation - ROTATION_THRESHHOLD, rand_rotation + ROTATION_THRESHHOLD]

func _on_slider_drag_started() -> void:
	text_slider.visible = false

func _physics_process(delta: float) -> void:
	value_velocity = lerp(value_velocity, 0.0, delta * 8)
	
	if !inserted:
		value_velocity = abs(prev_value_slider - slider.value)
		sliding_sound.volume_db = lerpf(-10.0, 1.0, minf(value_velocity * 10, 1.0)) if value_velocity > 0.01 else -80.0
	else:
		sliding_sound.volume_db = -80.0
	
	prev_value_slider = slider.value

func _on_slider_value_changed(value: float) -> void:
	var value_to_degrees := lerpf(90.0, -90.0, value)

	if value_to_degrees >= rotation_range[0] && value_to_degrees <= rotation_range[1]:
		circle_2_sprite.rotation_degrees = circle_1_sprite.rotation_degrees
		if !inserted:
			slide_in_sound.play()
			inserted = true
		return

	inserted = false

	circle_2_sprite.rotation_degrees = value_to_degrees

func canSkip() -> bool:
	return !text_slider.visible

func isWinning() -> bool:
	return circle_2_sprite.rotation_degrees >= rotation_range[0] && circle_2_sprite.rotation_degrees <= rotation_range[1]
