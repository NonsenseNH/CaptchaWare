extends Microgame

const CACTUS_SMALL_INSTANCE = preload("uid://rnbce2tcv4cw")
const CACTUS_BIG_INSTANCE = preload("uid://81qgltjkv3h8")

const SPEED_DIFFICULTY_SCALE = [700, 750, 800, 900]

@onready var dinosaurgame_bg: Parallax2D = $dinosaurgameBG
@onready var clouds: CPUParticles2D = $clouds

@onready var cactus_spawn: Marker2D = $CactusSpawn
@onready var cactus_spawn_rate: Timer = $CactusSpawnRate

@onready var sounds: Node = $the_dino/sounds

var died := false

@export var cur_speed := 0.0

func _ready() -> void:
	set_speed(SPEED_DIFFICULTY_SCALE[difficulty - 1])

func canSkip() -> bool:
	return died

func isWinning() -> bool:
	for i in sounds.get_children():
		i.volume_db = -80
	
	return !died

func set_speed(speed : float) -> void:
	dinosaurgame_bg.autoscroll = Vector2.LEFT * speed
	cur_speed = speed

func spawn_cactus() -> void:
	var cactus_type := [CACTUS_SMALL_INSTANCE, CACTUS_BIG_INSTANCE]
	var cactus_instance : cactus = cactus_type.pick_random().instantiate()

	cactus_instance.position = cactus_spawn.position
	cactus_instance.speed_set = cur_speed

	add_child(cactus_instance)

func _on_the_dino_killed() -> void:
	dinosaurgame_bg.autoscroll = Vector2.ZERO
	clouds.speed_scale = 0
	cactus_spawn_rate.stop()
	died = true

	skip_timer.emit()

func on_transition_complete() -> void:
	cactus_spawn_rate.start()

func _on_cactus_spawn_rate_timeout() -> void:
	spawn_cactus()
