extends Node

class_name Microgame

signal override_instruction_text(big:String, small:String)
signal set_camera_shake(intensity : float, duration : float)
signal skip_timer
signal end_microgame

var is_intro := false
var skipped := false

var difficulty : int = 1

var current_game_speed : = 0.0

var finished := false

var force_stopped := false

func stop_microgame() -> void:
	force_stopped = true

func force_end_mircogame() -> void:
	skipped = true
	end_microgame.emit()

func get_file_list(path : String, file_type : String = ".png") -> Array:
	var dir := ResourceLoader.list_directory(path)
	
	if !dir:
		print_debug(error_string(FAILED))
		return []
	
	var dir_array : Array = []
	
	for file in dir:
		if !file.contains(file_type): continue
		dir_array.append(file)
	
	return dir_array

func get_json_data(path : String) -> Dictionary:
	var dir := FileAccess.open(path + ".json", FileAccess.READ) 
	return JSON.parse_string(dir.get_as_text())

func canSkip() -> bool:
	return isWinning()

func isWinning() -> bool:
	return finished

func on_transition_complete() -> void:
	pass
