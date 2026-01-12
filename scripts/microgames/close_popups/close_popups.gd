extends Microgame

const POPUP_INSTANCE = preload("uid://bfin0va87eit7")
const BLOCKER_IMAGE_FILENAME := "blocker.png"

const AD_IMAGES_PATH := "res://sprites/close_popups/ads/"

@onready var pop_ups: Control = $popUps
@onready var count_down: Label = $ad/CountDown
@onready var timer: TextureProgressBar = $ad/timer
@onready var pop_up_timer: Timer = $PopUpTimer

var ad_images : Array = []
var cleared := false

const rand_pos_clamp = [Vector2(-246.0, 100.0), Vector2(611.0, 340.0)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_microgame.connect(close_all_popups)
	timer.max_value = pop_up_timer.wait_time

	ad_images = ResourceLoader.list_directory(AD_IMAGES_PATH)
	ad_images.shuffle()

func spawn_popup(image : String, is_blocker : bool = false) -> void:
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

func close_all_popups() -> void:
	for popup in pop_ups.get_children():
		if popup != null:
			popup.queue_free()
		await get_tree().create_timer(.025).timeout

func _on_pop_up_timer_timeout() -> void:
	var pop_up_blocker_chance := randi_range(3,8)

	for i in range(mini(ad_images.size(), 10)):
		if i == pop_up_blocker_chance:
			spawn_popup(BLOCKER_IMAGE_FILENAME, true)
		else:
			spawn_popup("ads/" + ad_images[i])
		await get_tree().create_timer(.025).timeout
	
	ad_images.clear()

func on_popup_closed() -> void:
	if pop_ups.get_child_count() <= 1 && !cleared:
		win()

func popup_blocker_clicked() -> void:
	freeze_timer()

	close_all_popups()
	win()

	await get_tree().create_timer(1).timeout

	end_microgame.emit()

func win() -> void:
	cleared = true
	skip_timer.emit()

func _on_timer_value_changed(value: float) -> void:
	count_down.text = str(int(ceil(value)))

func isWinning() -> bool:
	return cleared
