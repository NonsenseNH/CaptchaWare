extends Node
class_name SaveSystem

const _SAVE_PATH := "user://"

var save_paths : Dictionary = {}

func save(file_name : String, data_dictionary : Dictionary) -> void:
	var file = FileAccess.open(_SAVE_PATH + file_name, FileAccess.WRITE)
	file.store_var(data_dictionary)
	
	if !save_paths.has(file_name):
		save_paths[file_name] = data_dictionary

func load_data(file_name : String, data_dictionary : Dictionary = {}) -> Dictionary:
	var file : FileAccess
	
	if !save_paths.has(file_name):
		save_paths[file_name] = data_dictionary
	
	if !FileAccess.file_exists(_SAVE_PATH + file_name):
		if data_dictionary.is_empty():
			return {}
		
		file = FileAccess.open(_SAVE_PATH + file_name, FileAccess.WRITE)
		file.store_var(data_dictionary)
		return data_dictionary
	
	file = FileAccess.open(_SAVE_PATH + file_name, FileAccess.READ_WRITE)
	var loaded_save : Dictionary = file.get_var()
	var cur_save := data_dictionary
	
	for key in data_dictionary:
		if loaded_save.has(key):
			cur_save[key] = loaded_save[key]
	
	file.store_var(cur_save)
	
	return cur_save

func _notification(what: int) -> void:
	if what != NOTIFICATION_WM_CLOSE_REQUEST: return
	save_all_paths()

func save_all_paths() -> void:
	for i in save_paths:
		var file = FileAccess.open(_SAVE_PATH + i, FileAccess.WRITE)
		file.store_var(save_paths[i])
