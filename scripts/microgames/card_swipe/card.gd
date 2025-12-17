extends Node2D

const FAST_CAP = 0.35
const SLOW_CAP = 0.7

@onready var reader_text: Label = $'../topPart/Label'
@onready var lights: Sprite2D = $'../topPart/lights'
@onready var sounds: Node = $'../sounds'

var mouse_prev_position_x = 0.0

var card_swipe_timer : float = 0.0

var card_hovered := false

var card_grabbed := false
var card_moving := false

var card_can_swipe := false
var card_tweening := false

var tween_card_pos : Tween

signal swipe_completed

# x109.0 y371.265
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click") && card_hovered:
			if !card_tweening:
				sounds.get_node("insert").play()
				var tween_card_size := create_tween()
				tween_card_pos = create_tween()

				tween_card_pos.tween_property(self, "position", Vector2(6.0, 148.265), .75)
				tween_card_size.tween_property(self, "scale", Vector2.ONE * 1.36, .75)

				tween_card_size.finished.connect(card_on_reader)

				card_tweening = true
				return

			if !card_can_swipe: return
			mouse_prev_position_x = get_global_mouse_position().x

			tween_card_pos.stop()
			card_grabbed = true
			sounds.get_node("swipe").play()

		if Input.is_action_just_released("Left Click") && card_grabbed:
			card_grabbed = false
			card_moving = false

			var success_check = check_card_reader()

			tween_card_pos = create_tween()
				
			if success_check:
				card_can_swipe = false
				lights.frame = 1
				sounds.get_node("accept").play()

				var tween_card_size := create_tween()

				tween_card_pos.tween_property(self, "position", Vector2(109.0, 371.265), .75)
				tween_card_size.tween_property(self, "scale", Vector2.ONE * 1, .75)
			else:
				sounds.get_node("denied").play()
				lights.frame = 0
				tween_card_pos.tween_property(self, "position", Vector2(6.0, 148.265), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			
			card_swipe_timer = 0
	
	if event is InputEventMouseMotion:
		if !card_grabbed: return

		if !(mouse_prev_position_x + 10 < get_global_mouse_position().x || mouse_prev_position_x - 10 > get_global_mouse_position().x): return

		card_moving = !(position.x <= 6.0 || position.x >= 406.0)
		position = Vector2(clampf(get_global_mouse_position().x - 400, 6.0, 406.0) ,148.265)

func _process(delta):
	if card_moving:
		card_swipe_timer += delta

func check_card_reader() -> bool:
	if position.x < 406.0:
		reader_text.text = "BAD READ. TRY AGAIN."
		return false
	
	if card_swipe_timer < FAST_CAP:
		reader_text.text = "TOO FAST. TRY AGAIN."
		return false
	
	if card_swipe_timer > SLOW_CAP:
		reader_text.text = "TOO SLOW. TRY AGAIN."
		return false

	if card_swipe_timer >= FAST_CAP && card_swipe_timer <= SLOW_CAP:
		reader_text.text = "ACCEPTED CARD. THANK YOU."
		swipe_completed.emit()
		return true
	
	return false

func card_on_reader() -> void:
	card_can_swipe = true

	reader_text.text = "PLEASE SWIPE CARD"
	lights.visible = true

func _on_card_texture_mouse_exited() -> void:
	card_hovered = false

func _on_card_texture_mouse_entered() -> void:
	card_hovered = true
