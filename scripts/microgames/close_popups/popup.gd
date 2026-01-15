extends Control

const AD_IMAGES_PATH := "res://sprites/close_popups/"

@onready var ad_sprite: TextureRect = $ad
@onready var window_texture: ColorRect = $ad/window

@onready var bang_particles: CPUParticles2D = $bang

var is_blocker := false

var grabbed := false
var grab_offset := Vector2.ZERO

var focused := false
var clicked := false

signal block_popups
signal popup_closed

func _ready():
	if !is_blocker: return
	ad_sprite.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func set_popup_image(file_name : String) -> void:
	var popup_texture : Texture2D = load(AD_IMAGES_PATH + file_name)

	ad_sprite.texture = popup_texture

func _on_x_pressed() -> void:
	popup_closed.emit()
	queue_free()

func destroyed() -> void:
	bang_particles.restart()
	ad_sprite.visible = false

func _process(_delta: float) -> void:
	if grabbed:
		global_position = get_global_mouse_position() + grab_offset

func _on_window_tab_button_up() -> void:
	grabbed = false

func _on_window_tab_button_down() -> void:
	grab_offset = global_position - get_global_mouse_position()
	grabbed = true
	
	push_to_front()

func push_to_front() -> void:
	var parent := get_parent()
	parent.move_child(self, parent.get_child_count() - 1)

func _input(event: InputEvent) -> void:
	if !focused || clicked: return

	if event is InputEventMouseButton:
		if event.double_click:
			clicked = true
			block_popups.emit()

func _on_ad_mouse_exited() -> void:
	if is_blocker:
		focused = false

func _on_ad_mouse_entered() -> void:
	focused = is_blocker
	
func _on_window_focus_entered() -> void:
	push_to_front()

func _on_bang_finished() -> void:
	queue_free()
