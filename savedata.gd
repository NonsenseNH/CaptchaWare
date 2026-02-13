extends SaveSystem

const SAVE_SETTINGS = "settings"
const GAME_SAVE_NAME := "save_data"

const default_game_settings := {
	"master_volume" : 0.0,
	"music_volume" : 0.0,
	"sound_volume" : 0.0,
	"scroll_speed" : 0.03,
}

var game_settings := {
	"master_volume" : 0.0,
	"music_volume" : 0.0,
	"sound_volume" : 0.0,
	"scroll_speed" : 0.03,
}

var save_file := {
	"highscore" : 0,
	"previous_boss" : "",
	"beaten_full_game" : false,
	"endless_mode" : false
}

var stored_data := {
	"played_intro" : false,
	"previous_boss" : 0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_settings = load_data(SAVE_SETTINGS ,game_settings)
	
	save_file = load_data(GAME_SAVE_NAME, save_file)

func reset_all_settings() -> void:
	for i in default_game_settings.keys():
		game_settings[i] = default_game_settings[i]
	GameData.save_cur_data(GameData.SAVE_SETTINGS)

func save_cur_data(data_name : String) -> void:
	match data_name:
		SAVE_SETTINGS:
			save(SAVE_SETTINGS, game_settings)
		GAME_SAVE_NAME:
			save(GAME_SAVE_NAME, save_file)
