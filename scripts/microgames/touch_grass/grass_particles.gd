extends CPUParticles2D

func _skip_timered() -> void:
	queue_free()
