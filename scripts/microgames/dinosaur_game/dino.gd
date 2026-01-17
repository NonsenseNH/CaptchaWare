extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -1300.0

var buffer_jump_timer := 0.0

signal killed

var is_dead := false

func timers(delta : float) -> void:
	if buffer_jump_timer >= 0:
		buffer_jump_timer -= delta

func _physics_process(delta: float) -> void:
	if is_dead: return
	# Add the gravity.
	timers(delta)
	
	if not is_on_floor():
		velocity += (get_gravity() * 6)* delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		buffer_jump_timer = .5
	
	if is_on_floor() && buffer_jump_timer > 0:
		buffer_jump_timer = 0
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func _on_cactus_detector_area_entered(area: Area2D) -> void:
	if !area.get_parent() is cactus: return
	area.get_parent().speed_set = 0
	dead()

func dead() -> void:
	is_dead = true
	killed.emit()