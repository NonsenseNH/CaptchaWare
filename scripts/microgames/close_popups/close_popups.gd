extends Microgame

const POPUP_INSTANCE = preload("uid://bfin0va87eit7")
const BLOCKER_IMAGE_FILENAME := preload("uid://27g5xm4elkwk")

const DIFFICULTY_POPUP_COUNT := [5, 6, 7, 8]

const AD_IMAGES_PATH := "res://sprites/close_popups/ads/"

@onready var camera = get_tree().get_first_node_in_group("camera")

@onready var pop_ups: Control = $popUps
@onready var count_down: Label = $ad/CountDown
@onready var timer: TextureProgressBar = $ad/timer
@onready var pop_up_timer: Timer = $PopUpTimer
@onready var crosshair_sprite: Sprite2D = $crosshair

@onready var ticking_sound: AudioStreamPlayer = $sounds/tickingSound
@onready var riflesounds_sound: AudioStreamPlayer = $sounds/riflesounds
@onready var reload_sound: AudioStreamPlayer = $sounds/reload
@onready var popup_close_sound: AudioStreamPlayer = $sounds/popupClose
@onready var popup_sound: AudioStreamPlayer = $sounds/popup

var popup_amount := 5

var ad_images : Array = []
var cleared := false

const rand_pos_clamp = [Vector2(-246.0, 100.0), Vector2(611.0, 340.0)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_amount = DIFFICULTY_POPUP_COUNT[difficulty - 1]
	end_microgame.connect(times_up)
	timer.max_value = pop_up_timer.wait_time

	var cur_image_paths := ResourceLoader.list_directory(AD_IMAGES_PATH)

	for i in cur_image_paths:
		ad_images.append(load("res://sprites/close_popups/ads/" + i))
	
	print_debug(ad_images)
	
	ad_images.shuffle()

func times_up() -> void:
	close_all_popups()

func spawn_popup(image : Texture2D, is_blocker : bool = false) -> void:
	var popup_instance = POPUP_INSTANCE.instantiate()

	var rand_x = randi_range(int(rand_pos_clamp[0].x), int(rand_pos_clamp[1].x))
	var rand_y = randi_range(int(rand_pos_clamp[0].y), int(rand_pos_clamp[1].y))

	popup_instance.position = Vector2(rand_x, rand_y)
	popup_instance.is_blocker = is_blocker

	if is_blocker:
		popup_instance.block_popups.connect(popup_blocker_clicked)

	popup_instance.popup_closed.connect(on_popup_closed)

	pop_ups.add_child(popup_instance)
	
	popup_instance.set_popup_image(image)

func _process(_delta: float) -> void:
	timer.value = pop_up_timer.time_left

func close_all_popups(destroyed : = false) -> void:
	if cleared: return
	var popup_closing_sound := riflesounds_sound if destroyed else popup_close_sound

	for popup in pop_ups.get_children():
		if popup == null: continue
		popup_closing_sound.play()

		if destroyed:
			var crosshair_tween := create_tween()
			crosshair_tween.tween_property(crosshair_sprite , "position", popup.position, .07).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

			set_camera_shake.emit(3, .2)
			popup.destroyed()
			await get_tree().create_timer(.07).timeout
		else:
			popup.queue_free()
			await get_tree().create_timer(.025).timeout

func _on_pop_up_timer_timeout() -> void:
	ticking_sound.stop()

	var cam_tween := create_tween()
	cam_tween.tween_property(camera, "zoom", Vector2.ONE * 1.43, .07)

	set_camera_shake.emit(5, .5)

	var pop_up_blocker_chance := randi_range(3,popup_amount - 2)

	for i in range(mini(ad_images.size(), popup_amount)):
		popup_sound.play()

		if i == pop_up_blocker_chance:
			spawn_popup(BLOCKER_IMAGE_FILENAME, true)
		else:
			spawn_popup(ad_images[i])
		await get_tree().create_timer(.025).timeout
	
	ad_images.clear()

func on_popup_closed() -> void:
	if pop_ups.get_child_count() <= 1 && !cleared:
		win()

func popup_blocker_clicked() -> void:
	crosshair_sprite.visible = true
	
	var crosshair_tween := create_tween()
	crosshair_tween.tween_property(crosshair_sprite , "position", pop_ups.get_child(pop_ups.get_child_count() -1).position, .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	reload_sound.play()
	freeze_timer()

	await get_tree().create_timer(.5).timeout

	close_all_popups(true)

	await get_tree().create_timer(.5).timeout
	
	win()
	end_microgame.emit()

func win() -> void:
	cleared = true
	skip_timer.emit()

func on_transition_complete() -> void:
	ticking_sound.play()

	var cam_tween := create_tween()
	cam_tween.tween_property(camera, "zoom", Vector2.ONE * 1.80, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)	

func _on_timer_value_changed(value: float) -> void:
	count_down.text = str(int(ceil(value)))

func isWinning() -> bool:
	return cleared
