extends TextureRect

@export var parallax_offset_amount : float = 0
var parallax_offset := Vector2.ZERO

@onready var cur_pos := position

func _ready() -> void:
	parallax_system()

func parallax_system() -> void:
	if parallax_offset_amount == 0: return
	parallax_offset = lerp(Vector2.ZERO, get_local_mouse_position(), parallax_offset_amount / 100.0)
	position = cur_pos + parallax_offset

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		parallax_system()
