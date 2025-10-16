extends Microgame

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var v_scroll_bar : VScrollBar = scroll_container.get_v_scroll_bar()

@onready var check_box: CheckBox = $CheckBox

@onready var the_end_of_bar : int

@onready var scroll_fast_sound: AudioStreamPlayer = $scroll_fast
@onready var scroll_impact_sound: AudioStreamPlayer = $scroll_impact

var scroll_length : Dictionary = {
	4 : 44675.172,
	3 : 34443.551,
	2 : 22117.24,
	1 : 22117.24
}

var scroll_velocity := 0.0
var full_tos_text : String

var cur_article : int = 0

func _ready() -> void:
	v_scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v_scroll_bar.value_changed.connect(on_value_changed)
	v_box_container.custom_minimum_size = Vector2.DOWN * scroll_length[difficulty]
	the_end_of_bar = int(v_box_container.custom_minimum_size.y) - 376

func _input(event: InputEvent) -> void:
	if force_stopped: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			scroll_velocity -= 20
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			scroll_velocity += 20

func _process(delta: float) -> void:
	scroll_container.scroll_vertical += scroll_velocity * (minf(delta * 20, 1))
	scroll_velocity = lerpf(scroll_velocity, 0, minf(delta, 1))

var prev_value : int = 0
var value_velocity : float = 0.0
func on_value_changed(value : float) -> void:
	if prev_value == int(value): return
	
	value_velocity = value - float(prev_value)
	
	scroll_fast_sound.volume_db = lerpf(-80, -10, minf(abs(value_velocity) / 20.0, 1.0))
	set_camera_shake.emit(scroll_velocity / 200.0, 0)
	
	if int(value) == the_end_of_bar || int(value) == 0:
		finished_scrolling()
	
	prev_value = int(value)

func finished_scrolling() -> void:
	if abs(scroll_velocity) > 180.0:
		set_camera_shake.emit(10, 0.5)
		scroll_impact_sound.play()
	scroll_fast_sound.volume_db = -80
	
	if sign(scroll_velocity) == 1:
		check_box.disabled = false

func stop_microgame() -> void:
	super.stop_microgame()
	scroll_velocity = 0
	set_camera_shake.emit(0, 0)
	scroll_fast_sound.volume_db = -80

func _on_check_box_toggled(toggled_on: bool) -> void:
	if !toggled_on: return
	check_box.disabled = true
	skip_timer.emit()
	finished = true
