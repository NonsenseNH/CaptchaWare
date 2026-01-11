extends Control

signal button_answered(button: Button)
@onready var button: Button = $Button
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var cur_numbers : int = 1

func disable_buttons(answer : int, correct : bool) -> void:
	if cur_numbers != answer:
		button.text = "..."
	else:
		if correct:
			button.self_modulate = Color("00fd9e")
		else:
			button.self_modulate = Color("ff3951")
	
	button.disabled = true

func reaveal_numbers() -> void:
	button.disabled = false
	button.text = str(cur_numbers)

func _on_button_button_down() -> void:
	button_answered.emit(button)
	audio_stream_player.play()
