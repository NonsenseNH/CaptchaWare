extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -950.0

var buffer_jump_timer := 0.0

func timers(delta : float) -> void:
	if buffer_jump_timer >= 0:
		buffer_jump_timer -= delta

func _physics_process(delta: float) -> void:
	# Add the gravity.
	timers(delta)
	
	if not is_on_floor():
		velocity += (get_gravity() * 4)* delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		buffer_jump_timer = .5
	
	if is_on_floor() && buffer_jump_timer > 0:
		buffer_jump_timer = 0
		velocity.y = JUMP_VELOCITY

	move_and_slide()
