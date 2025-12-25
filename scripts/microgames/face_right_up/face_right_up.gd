extends Microgame

const IMAGES_FOLDER = "res://sprites/face_right_up/images/"

const DOT_INSTANCE = "res://instances/faceUpRight/dot.tscn"

const ROTATE_INTERVAL = 45

const DIFFICULTY_AMOUNT = [1, 1, 2, 3]

@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var the_ball: Node2D = $Circle
@onready var anims: AnimationPlayer = $anims
@onready var align_timer: Timer = $alignTimer
@onready var ball_image: TextureRect = $Circle/circle/image

var image_pool : PackedStringArray = []

var how_many_balls : int = 1
var current_ball : int = 1

var ball_spin_dir : int = 0

var cur_degrees : float = 0.0

var can_spin : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	how_many_balls = DIFFICULTY_AMOUNT[difficulty - 1]

	get_all_images()

	the_ball.rotation_degrees = set_random_rotation()
	cur_degrees = the_ball.rotation_degrees

	for i in range(how_many_balls):
		var dot_instance = load(DOT_INSTANCE).instantiate()
		hbox_container.add_child(dot_instance)

func set_random_rotation() -> float:
	var target_rotation : float = 0.0

	while target_rotation == 0.0:
		target_rotation = (randi_range(-7, 7) * ROTATE_INTERVAL)
	
	return target_rotation

func get_all_images() -> void:
	var list := get_file_list(IMAGES_FOLDER)
	list.shuffle()

	for i in range(how_many_balls):
		image_pool.append(list[i])

	print_debug(image_pool)

	set_ball_image()

func set_ball_image() -> void:
	ball_image.texture = load(IMAGES_FOLDER + image_pool[current_ball - 1])

func push_ball() -> void:
	if !can_spin:
		return
	
	if anims.is_playing():
		anims.stop()
	anims.play("bounce")

	var ball_tween := create_tween()
	
	var target_rotation : float = cur_degrees + (ROTATE_INTERVAL * ball_spin_dir)

	ball_tween.tween_property(the_ball, "rotation_degrees", target_rotation, 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	cur_degrees = target_rotation

func done_check() -> void:
	var normalized_rotation : float = abs(fmod(cur_degrees, 360.0))

	if normalized_rotation < 0.3 || normalized_rotation > 359.8:
		align_timer.start()
	else:
		align_timer.stop()

func switch_image() -> void:
	the_ball.rotation_degrees = set_random_rotation()
	cur_degrees = the_ball.rotation_degrees

	set_ball_image()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("right"):
			_on_arrow_right_pressed()
		if Input.is_action_just_pressed("left"):
			_on_arrow_left_pressed()

func _on_arrow_right_pressed() -> void:
	ball_spin_dir = -1
	push_ball()

	done_check()

func _on_arrow_left_pressed() -> void:
	ball_spin_dir = 1
	push_ball()

	done_check()


func _on_align_timer_timeout() -> void:
	can_spin = false
	
	hbox_container.get_child(current_ball-1).get_child(0).frame = 1

	if how_many_balls > current_ball:
		current_ball += 1
		anims.play("switch")
		return
	
	skip_timer.emit()
	finished = true
	anims.play("finish")

func isWinning() -> bool:
	return current_ball >= how_many_balls && (!align_timer.is_stopped() || finished)

func _on_anims_animation_finished(anim_name: StringName) -> void:
	if anim_name != "switch":
		return
	
	can_spin = true
