extends Control

@onready var anim: AnimationPlayer = $anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_decline_pressed() -> void:
	queue_free()


func _on_accept_pressed() -> void:
	anim.play("answered")
