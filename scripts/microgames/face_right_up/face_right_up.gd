extends Microgame

const IMAGES_FOLDER = "res://sprites/face_right_up/images/"
const DOT_INSTANCE = "res://instances/faceUpRight/dot.tscn"
const ROTATE_INTERVAL = 22.5

@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var the_ball: Node2D = $Circle
@onready var anims: AnimationPlayer = $anims

var image_pool : PackedStringArray = [
	"test"
]

var how_many_balls : int = 1
var current_ball : int = 1

var ball_spin_dir : int = 0

var cur_degrees : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var target_rotation : float = 0.0

	while target_rotation == 0.0:
		target_rotation = (randi_range(-7, 7) * ROTATE_INTERVAL)
	
	the_ball.rotation_degrees = (randi_range(-7, 7) * ROTATE_INTERVAL)
	cur_degrees = the_ball.rotation_degrees

	for i in range(how_many_balls):
		var dot_instance = load(DOT_INSTANCE).instantiate()
		hbox_container.add_child(dot_instance)

func get_all_images() -> void:
	image_pool = get_file_list(IMAGES_FOLDER)

func push_ball() -> void:
	if anims.is_playing():
		anims.stop()
	anims.play("bounce")

	var ball_tween := create_tween()
	
	var target_rotation : float = cur_degrees + (ROTATE_INTERVAL * ball_spin_dir)

	ball_tween.tween_property(the_ball, "rotation_degrees", target_rotation, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	print_debug("Target Rotation: " + str(target_rotation))

	cur_degrees = target_rotation

func done_check() -> void:
	var normalized_rotation : float = fmod(cur_degrees, 360.0)
	
	if normalized_rotation == 0.0:
		print_debug("yes")

func switch_image() -> void:
	pass

func _on_arrow_right_pressed() -> void:
	ball_spin_dir = -1
	push_ball()

	done_check()

func _on_arrow_left_pressed() -> void:
	ball_spin_dir = 1
	push_ball()

	done_check()
