extends Node2D

var mouse_hovering : bool = false
var set_click_offset : Vector2 = Vector2.ZERO
var selected : bool = false

var cur_puzzle_hole : Node2D = null
var cur_index : int = 0

@onready var check: Sprite2D = $check

@onready var puzzle_piece_mask: Sprite2D = $puzzlePieceMask
@onready var click_shape: CollisionShape2D = $clickArea/clickShape

@onready var puzzle_place: AudioStreamPlayer = $PuzzlePlace
@onready var puzzle_grab: AudioStreamPlayer = $puzzleGrab
@onready var point_hitbox: RayCast2D = $RayCast2D

signal count_puzzles
func set_puzzle_texture(puzzleMaskIndex: int = 0, puzzleTexture: Texture2D = null, puzzleTexturePos : Vector2 = Vector2.ZERO) -> void:
	
	puzzle_piece_mask.texture = load("res://sprites/puzzle_piece/masks/puzzle" + str(puzzleMaskIndex) + ".png")
	
	var puzzle_mask_shader = puzzle_piece_mask.material as ShaderMaterial
	puzzle_mask_shader.set_shader_parameter("base_texture", puzzleTexture)
	puzzle_mask_shader.set_shader_parameter("base_texture_offset", Vector2(50, 50) - puzzleTexturePos)
	
	cur_index = puzzleMaskIndex

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("Left Click") && mouse_hovering:
			selected = true
			set_click_offset = global_position - get_global_mouse_position()
			puzzle_grab.play()
			check.visible = false
			
			var puzzle_tween : Tween = create_tween()
			puzzle_tween.tween_property(self, "scale", Vector2.ONE * 1.2, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		
		if Input.is_action_just_released("Left Click") && selected:
			selected = false
			puzzle_place.play()
			hole_check()
			
			var puzzle_tween : Tween = create_tween()
			puzzle_tween.tween_property(self, "scale", Vector2.ONE * 1.0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).from(Vector2.ONE * 0.9)
	
	if event is InputEventMouseMotion && (selected && Input.is_action_pressed("Left Click")):
		global_position = get_global_mouse_position() + set_click_offset

func hole_check() -> void:
	if point_hitbox.get_collider() == null || point_hitbox.get_collider().get_parent() != cur_puzzle_hole: return
	
	var hole : Node2D = point_hitbox.get_collider().get_parent()
	global_position = hole.global_position
	check.visible = true
	lock_puzzle_piece()
	count_puzzles.emit()

func lock_puzzle_piece() -> void:
	click_shape.disabled = true

func _on_click_area_mouse_entered() -> void:
	mouse_hovering = true

func _on_click_area_mouse_exited() -> void:
	mouse_hovering = false
