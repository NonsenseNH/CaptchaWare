extends Node2D

const SAVE_NAME = "settings"

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

const default_game_settings := {
	"master_volume" : 0.0,
	"music_volume" : 0.0,
	"sound_volume" : 0.0,
	"scroll_speed" : 0.03,
}

@onready var settings_sliders: VBoxContainer = $menuStuff/windowmenustuff/menus/options/VBoxContainer

@onready var windowmenustuff: Control = $menuStuff/windowmenustuff
@onready var menus: Control = $menuStuff/windowmenustuff/menus

@onready var bg: TextureRect = $"../MicrogameGameplay/bg"

@onready var volume_check: AudioStreamPlayer = $menuStuff/windowmenustuff/menus/options/VolumeCheck

var game_settings := {
	"master_volume" : 0.0,
	"music_volume" : 0.0,
	"sound_volume" : 0.0,
	"scroll_speed" : 0.03,
}

func _ready() -> void:
	load_settings()

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
	game_settings = SaveHandler.load_data(SAVE_NAME ,game_settings)
	
	var game_setting_values := [
		game_settings.master_volume,
		game_settings.music_volume,
		game_settings.sound_volume,
		game_settings.scroll_speed
	]
	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = game_setting_values[i]
	
	for i in SettingsSliders.size():
		set_value_settings(i)

func set_value_settings(value_type : SettingsSliders) -> void:
	var cur_slider := settings_sliders.get_child(value_type).get_child(0)
	
	match value_type:
		SettingsSliders.MASTER:
			game_settings.master_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), cur_slider.value)
		SettingsSliders.MUSIC:
			game_settings.music_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), cur_slider.value)
		SettingsSliders.SOUND:
			game_settings.sound_volume = cur_slider.value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), cur_slider.value)
		SettingsSliders.SCROLL:
			game_settings.scroll_speed = cur_slider.value
			bg.material.set("shader_parameter/set_speed", cur_slider.value)
	
	SaveHandler.save(SAVE_NAME, game_settings)

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
	for i in default_game_settings.keys():
		game_settings[i] = default_game_settings[i]
	SaveHandler.save(SAVE_NAME, game_settings)
	
	var game_setting_values := [
		game_settings.master_volume,
		game_settings.music_volume,
		game_settings.sound_volume,
		game_settings.scroll_speed
	]
	
	for i in settings_sliders.get_child_count():
		settings_sliders.get_child(i).get_child(0).value = game_setting_values[i]
	
	for i in SettingsSliders.size():
		set_value_settings(i)
