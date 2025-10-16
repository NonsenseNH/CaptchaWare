extends HBoxContainer

func set_failed_attempt(index:int = 0) -> void:
	var cur_attempt_box = get_child(index)
	cur_attempt_box.get_child(0).self_modulate = Color(1,1,1,1)
