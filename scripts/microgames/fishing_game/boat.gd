extends Node2D

const BOAT_OFFSET_X = 103.5
const MOUSE_OFFSET = Vector2(9,-20)

var boat_velocity := Vector2.ZERO

var prev_mouse_pos := Vector2.ZERO

@onready var fishing_line: Line2D = $'boat_sprite/Line2D'

@onready var mouse_pos := get_global_mouse_position()
@onready var mouse_pos_marker: Marker2D = $boat_sprite/mouse_pos
# (406.272, 276.9047), (814.8995, 684.6229)
@onready var hook: Sprite2D = $boat_sprite/mouse_pos/hook

var surfaced := false

var failed := false
var win := false

signal get_fish

@onready var fishing_rod_sound: AudioStreamPlayer = $'../sounds/FishingRod'

func _ready() -> void:
	mouse_pos_marker.global_position = mouse_pos

func _input(event: InputEvent) -> void:
	if failed: return
	if event is InputEventMouseMotion:
		var mouse_x = clampf(get_global_mouse_position().x, 440.272, 780.8995)
		var mouse_y = clampf(get_global_mouse_position().y, 210.9047, 600.6229)

		mouse_pos = Vector2(mouse_x, mouse_y if !win else 210.9047)

		global_position = Vector2(mouse_pos.x + BOAT_OFFSET_X, global_position.y)

		boat_velocity += (mouse_pos - prev_mouse_pos)

		prev_mouse_pos = mouse_pos

		collect_fish()

func collect_fish() -> void:
	if mouse_pos.y > 260:
		surfaced = false 
		return
	
	if surfaced: return
	get_fish.emit()
	surfaced = true 

func success_microgame() -> void:
	win = true

func _physics_process(delta: float) -> void:
	mouse_pos_marker.global_position = mouse_pos + MOUSE_OFFSET

	boat_velocity = lerp(boat_velocity, Vector2.ZERO, delta * 15)
	rotation = clampf(boat_velocity.x * 0.005, -.15, 0.15)
	
	fishing_line.set_point_position(1, mouse_pos_marker.position)

	fishing_rod_sound.volume_db = lerpf(-50, -5, minf(abs(boat_velocity.y) / 50, 1))
