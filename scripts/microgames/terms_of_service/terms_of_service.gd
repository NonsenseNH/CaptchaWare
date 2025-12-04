extends Microgame

const FONT_SEPARATION := 23

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v_box_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var v_scroll_bar : VScrollBar = scroll_container.get_v_scroll_bar()

@onready var check_box: CheckBox = $CheckBox

@onready var the_end_of_bar : int

@onready var scroll_fast_sound: AudioStreamPlayer = $scroll_fast
@onready var scroll_impact_sound: AudioStreamPlayer = $scroll_impact

var scroll_velocity := 0.0
var full_tos_text : PackedStringArray

var scroll_length : Array = [
	20792.0,
	20792.0,
	32338.0,
	40917.0
]
var article_amount_set : Array = [
	35,
	35,
	65,
	100
]

@onready var article_limit : int = article_amount_set[difficulty - 1] - 3
var cur_article : int = 0
var cur_article_pos_check : float = 0
var cur_article_pos_offset : float = 0

func _ready() -> void:
	full_tos_text = get_tos_text(article_amount_set[difficulty - 1])
	
	v_scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v_scroll_bar.value_changed.connect(on_value_changed)
	v_box_container.custom_minimum_size = Vector2.DOWN * scroll_length[difficulty - 1]
	the_end_of_bar = int(v_box_container.custom_minimum_size.y) - 376
	
	set_up_articles()

func set_up_articles() -> void:
	var prev_offset_text := 0
	var prev_y_pos := 0
	
	for i in v_box_container.get_child_count():
		var cur_child := v_box_container.get_child(i)
		var rich_text_child := cur_child.get_child(0)
		
		if i == 0:
			cur_article_pos_check = (rich_text_child.get_line_count() * FONT_SEPARATION) + FONT_SEPARATION
		
		rich_text_child.text = full_tos_text[i]
		rich_text_child.position.y = prev_y_pos + (prev_offset_text * FONT_SEPARATION) + (FONT_SEPARATION if i != 0 else 0)
		
		prev_y_pos = rich_text_child.position.y
		prev_offset_text = rich_text_child.get_line_count()
	
	cur_article_pos_offset = prev_y_pos + (prev_offset_text * FONT_SEPARATION) + FONT_SEPARATION

func _input(event: InputEvent) -> void:
	if force_stopped: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			scroll_velocity += 20

func _process(delta: float) -> void:
	scroll_container.scroll_vertical += int(scroll_velocity * minf(delta * 20.0, 1.0))
	scroll_velocity = lerpf(scroll_velocity, 0, minf(delta, 1))

var prev_value : int = 0
var value_velocity : float = 0.0
func on_value_changed(value : float) -> void:
	if prev_value == int(value): return
	
	tos_scrolling_system(int(value))
	
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

func tos_scrolling_system(scrolling_value : int) -> void:
	if cur_article_pos_check >= scrolling_value || cur_article > article_limit: return
	update_tos_text(cur_article)
	cur_article += 1

func update_tos_text(article_index : int) -> void:
	var cur_vbox_child := article_index % 4
	var next_vbox_child := (article_index + 1) % 4
	var cur_article_child := v_box_container.get_child(cur_vbox_child).get_child(0)
	
	cur_article_child.text = full_tos_text[mini(article_index + 4, full_tos_text.size() - 1)]
	cur_article_child.position.y = cur_article_pos_offset
	
	cur_article_pos_offset = cur_article_child.position.y + (cur_article_child.get_line_count() * FONT_SEPARATION) + FONT_SEPARATION
	
	var next_article_child := v_box_container.get_child(next_vbox_child).get_child(0)
	cur_article_pos_check += (FONT_SEPARATION * next_article_child.get_line_count()) + FONT_SEPARATION

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

func get_tos_text(article_count : int) -> PackedStringArray:
	var text_file := FileAccess.open("res://scripts/microgames/terms_of_service/the_terms_of_service.txt", FileAccess.READ).get_as_text()
	var text_array : PackedStringArray = []
	var temp_array : PackedStringArray = []
	
	temp_array = text_file.split("[br][br]", false)
	
	for i in range(article_count + 2):
		text_array.append(temp_array[i])
	
	return text_array
