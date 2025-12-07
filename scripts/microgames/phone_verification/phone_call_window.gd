extends Control

var correct_one: bool = false

var cur_number_text: String = ""

@onready var phone_number_node: Label = $PhoneNumber
@onready var anim: AnimationPlayer = $anim

@onready var phone_audio: AudioStreamPlayer = $phoneAudio

@onready var ring_time: Timer = $ring_time

signal call_answered()
signal call_declined()

var answered: bool = false

func _on_decline_pressed() -> void:
	ring_time.stop()

	call_declined.emit()
	end_call()

func _on_accept_pressed() -> void:
	ring_time.stop()

	if !answered:
		anim.play("answered")
		phone_audio.play()
		call_answered.emit()
	else:
		end_call()
	answered = true


func _on_phone_audio_finished() -> void:
	end_call()

func end_call() -> void:
	phone_audio.stop()
	
	if answered:
		anim.play("answered_end")
	else:
		anim.play("ignored")
	
	await get_tree().create_timer(0.5).timeout
	
	queue_free()

func _on_ring_time_timeout() -> void:
	end_call()
