extends Microgame

@onready var line_edit: LineEdit = $LineEdit

var cur_text = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var image_list : Array = get_file_list("res://sprites/type_captcha")
	cur_text = image_list.pick_random().replace(".png", "")
	
	override_instruction_text.emit("res://sprites/type_captcha/" + cur_text + ".png")
	
	line_edit.grab_focus.call_deferred()

func isWinning() -> bool:
	super.isWinning()
	return line_edit.text == cur_text

func canSkip() -> bool:
	return line_edit.text.strip_edges() != ""

func _on_line_edit_text_changed(_new_text: String) -> void:
	if is_intro: return
	set_camera_shake.emit(3, 0.25)
