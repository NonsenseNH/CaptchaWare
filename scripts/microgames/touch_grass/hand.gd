extends Node2D

const GRASS_PARTICLES = preload("uid://ck1pnmnev0nln")

@onready var hand_position: Marker2D = $"../handPosition"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var grass: TextureRect = $".."
@onready var particles: Node2D = $particles

@export var gameplay_code : Microgame
var thumb_anim_played = false

func _ready() -> void:
	global_position = Vector2(clampf(get_global_mouse_position().x, 414.0, 814.0), clampf(get_global_mouse_position().y, 356.0, 600))

func _input(event: InputEvent) -> void:
	if gameplay_code.finished: 
		if !thumb_anim_played:
			animation_player.play("thumbs up")
			thumb_anim_played = true
		return
	
	if event is InputEventMouseMotion:
		
		global_position = Vector2(clampf(get_global_mouse_position().x, 414.0, 814.0), clampf(get_global_mouse_position().y, 356.0, 600))
		
		global_rotation = global_position.direction_to(hand_position.global_position).angle() + 250
	
	if !(event is InputEventMouseButton): return
	
	if Input.is_action_just_pressed("Left Click"):
		animation_player.play("grab")
	
	if Input.is_action_just_released("Left Click"):
		animation_player.play("open")

func spawn_grass_particle():
	var grass_instance = GRASS_PARTICLES.instantiate()
	grass_instance.texture = grass.texture
	particles.add_child(grass_instance)
	grass_instance.restart()
