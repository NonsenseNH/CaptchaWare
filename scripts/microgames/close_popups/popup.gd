extends Control

const AD_IMAGES_PATH := "res://sprites/close_popups/ads/"

@onready var ad_sprite: TextureRect = $ad

var grabbed := false
var grab_offset := Vector2.ZERO

signal popup_closed

func set_popup_image(file_name : String) -> void:
	var popup_texture : Texture2D = load(AD_IMAGES_PATH + file_name)

	ad_sprite.texture = popup_texture

func _on_x_pressed() -> void:
	popup_closed.emit()
	queue_free()

func _process(_delta: float) -> void:
	if grabbed:
		global_position = get_global_mouse_position() + grab_offset

func _on_window_tab_button_up() -> void:
	grabbed = false

func _on_window_tab_button_down() -> void:
	grab_offset = global_position - get_global_mouse_position()
	grabbed = true
	
	var parent := get_parent()
	parent.move_child(self, parent.get_child_count() - 1)
