extends Control

var correct_one: bool = false

var cur_number_text: String = ""

@onready var phone_number_node: Label = $PhoneNumber
@onready var anim: AnimationPlayer = $anim

@onready var phone_audio: AudioStreamPlayer = $phoneAudio

signal call_answered()
signal call_declined()

var answered: bool = false

func _on_decline_pressed() -> void:
	call_declined.emit()
	queue_free()

func _on_accept_pressed() -> void:
	if !answered:
		anim.play("answered")
		phone_audio.play()
		call_answered.emit()
	else:
		queue_free()
	answered = true


func _on_phone_audio_finished() -> void:
	queue_free()
