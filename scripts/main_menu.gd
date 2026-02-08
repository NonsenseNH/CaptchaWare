extends Node2D

enum MenuType {
	SETTINGS,
	CREDITS
}

enum SettingsSliders{
	MASTER,
	MUSIC,
	SOUND,
	SCROLL
}

@onready var settings_sliders: VBoxContainer = $menuStuff/windowmenustuff/menus/options/VBoxContainer

@onready var windowmenustuff: Control = $menuStuff/windowmenustuff
@onready var menus: Control = $menuStuff/windowmenustuff/menus

@onready var bg: TextureRect = $"../MicrogameGameplay/bg"

@onready var volume_check: AudioStreamPlayer = $menuStuff/windowmenustuff/menus/options/VolumeCheck

@onready var ui_anim: AnimationPlayer = $"../CanvasLayer/AnimationPlayer"

@onready var endless_mode: CheckButton = $menuStuff/endless_mode

func _ready() -> void:
	load_settings()
	endless_mode.visible = GameData.save_file.beaten_full_game

func _on_credits_pressed() -> void:
	open_menu(MenuType.CREDITS)

func _on_settings_pressed() -> void:
	open_menu(MenuType.SETTINGS)

func open_menu(menu_type : MenuType) -> void:
	windowmenustuff.visible = true

	for i in menus.get_children():
		i.visible = false
	
	menus.get_child(menu_type).visible = true

func _on_close_menu_pressed() -> void:
	windowmenustuff.visible = false
	bg.self_modulate = Color("ffffff00")

func load_settings() -> void:
	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = GameData.game_settings.values()[i]
	
	for i in SettingsSliders.size():
		set_value_settings(i)
	
	endless_mode.button_pressed = GameData.save_file.endless_mode

func set_value_settings(value_type : SettingsSliders) -> void:
	var cur_slider := settings_sliders.get_child(value_type).get_child(0)
	
	match value_type:
		SettingsSliders.MASTER:
			GameData.game_settings.master_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), cur_slider.value)
		SettingsSliders.MUSIC:
			GameData.game_settings.music_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), cur_slider.value)
		SettingsSliders.SOUND:
			GameData.game_settings.sound_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), cur_slider.value)
		SettingsSliders.SCROLL:
			GameData.game_settings.scroll_speed = cur_slider.value
			bg.material.set("shader_parameter/set_speed", cur_slider.value)
	
	GameData.save_cur_data(GameData.SAVE_SETTINGS)

func _on_scroll_speed_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.SCROLL)
	bg.self_modulate = Color("e3e3e35a")

func _on_sound_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.SOUND)
	volume_check.bus = &"Sounds"
	volume_check.play()

func _on_music_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.MUSIC)
	volume_check.bus = &"Music"
	volume_check.play()

func _on_master_volume_drag_ended(_value_changed: bool) -> void:
	set_value_settings(SettingsSliders.MASTER)
	volume_check.bus = &"Master"
	volume_check.play()

func _on_reset_default_pressed() -> void:
	GameData.reset_all_settings()
	
	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = GameData.game_settings.values()[i]
	
	for i in SettingsSliders.size():
		set_value_settings(i)

func _on_submit_button_pressed() -> void:
	ui_anim.play("end")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "end": return
	get_tree().change_scene_to_file("uid://b1ie1wbaj5lne")


func _on_endless_mode_toggled(toggled_on: bool) -> void:
	GameData.save_file.endless_mode = toggled_on
	GameData.save_cur_data(GameData.GAME_SAVE_NAME)
