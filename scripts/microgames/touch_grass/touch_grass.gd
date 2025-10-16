extends Microgame

@onready var grass: TextureRect = $grass
const GRASS_IMAGE_DIR = "res://sprites/touch_grass/grass_images"

@onready var progress_bar: ProgressBar = $ProgressBar
var points_percentage : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var image_array : Array = get_file_list(GRASS_IMAGE_DIR)
	grass.texture = load(GRASS_IMAGE_DIR + "/" + image_array.pick_random())
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if force_stopped: return
	if isWinning() && !finished:
		skip_timer.emit()
		finished = true
		return
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click"):
			set_camera_shake.emit(3, 0.25)
			points_percentage += 5

func _process(delta: float) -> void:
	progress_bar.value = lerpf(progress_bar.value, points_percentage, minf(delta * 20, 1))

func canSkip() -> bool:
	return points_percentage > 100

func isWinning() -> bool:
	return points_percentage > 100
