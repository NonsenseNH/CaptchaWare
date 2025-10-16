extends Microgame

const IMAGE_DIR : String = "res://sprites/do_nothing/"
@onready var image: TextureRect = $image
var has_skipped : bool = false
func _ready() -> void:
	var cur_image : Array = get_file_list(IMAGE_DIR)
	image.texture = load(IMAGE_DIR + cur_image.pick_random())

func canSkip() -> bool:
	has_skipped = true
	return true

func isWinning() -> bool:
	return !has_skipped
