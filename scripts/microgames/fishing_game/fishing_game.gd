extends Microgame

const FISH_INSTANCE = preload("uid://rebue6f2d3vi")
const SHARK_INSTANCE = preload("uid://8jnviul8fcqk")

const INSTANCES_ARRAY = [FISH_INSTANCE, SHARK_INSTANCE]
const SPAWN_DIR = [530.0, -140.0]

const DIFFICULTY_ARRAY ={
	"fishes_to_collect" : [5, 6 ,7 ,8],
	"shark_chance" : [12, 14, 16, 20],
	"spawn_rate" : [0.5, .45, .3, .2]
}

@onready var boat: Node2D = $boat
@onready var fishes: Node2D = $fishes

@onready var mouse_pos_marker: Marker2D = $boat/boat_sprite/mouse_pos

@onready var score: Label = $score

var grabbed := false

var collected_fishes := 0

var amount_of_sharks_on_screen := 0
var max_sharks := 1
var shark_chance_value := 0

var max_fishes := 5

var cur_fishes : Fish = null

@onready var spawn_timer: Timer = $SpawnTimer

@onready var shark_bite_sound: AudioStreamPlayer = $sounds/SharkBite
@onready var fish_hooked_sound: AudioStreamPlayer = $sounds/FishHooked
@onready var collected_fish_sound: AudioStreamPlayer = $sounds/CollectedFish
@onready var win_sound: AudioStreamPlayer = $sounds/Win

@onready var tutorial: Label = $tutorial

var has_shown_tutorial := false

signal scare_fishes

func _ready() -> void:
	max_fishes = DIFFICULTY_ARRAY.fishes_to_collect[difficulty - 1]
	shark_chance_value = DIFFICULTY_ARRAY.shark_chance[difficulty - 1]
	spawn_timer.wait_time = DIFFICULTY_ARRAY.spawn_rate[difficulty - 1]

	score.text = "0/" + str(max_fishes) + " FISHES"

func _on_visible_area_body_exited(body: Node2D) -> void:
	if !(body is Fish && body != null): return

	if body.fish_type == "shark":
		amount_of_sharks_on_screen -= 1
	
	body.queue_free()

func _on_fish_failed_microgame() -> void:
	if boat.win || boat.failed: return

	skip_timer.emit()
	scare_fishes.emit()
	boat.failed = true
	boat.hook.visible = false
	shark_bite_sound.play()
	spawn_timer.stop()

func _on_spawn_timer_timeout() -> void:
	spawn_fish()

func spawn_fish() -> void:
	var shark_chance := randi_range(0,100)
	var spawn_shark := shark_chance < shark_chance_value && max_sharks > amount_of_sharks_on_screen

	var fish_instance : Fish = INSTANCES_ARRAY[int(spawn_shark)].instantiate()
	var direction_facing := randi_range(0, 1)

	if spawn_shark:
		amount_of_sharks_on_screen += 1
	
	scare_fishes.connect(fish_instance.run_away)

	fish_instance.position = Vector2(SPAWN_DIR[direction_facing], randf_range(219.695, 481.695))

	if direction_facing == 0:
		direction_facing = -1
	
	fish_instance.cur_dir = direction_facing

	fish_instance.fish_grabbed.connect(fish_collecting)
	fish_instance.failed_microgame.connect(_on_fish_failed_microgame)

	fishes.add_child(fish_instance)

func fish_collecting(fish_thing : Fish) -> void:
	if grabbed || boat.failed || boat.win: return

	if !has_shown_tutorial:
		tutorial.visible = true
		has_shown_tutorial = true

	fish_thing.rotation_degrees = -90 * fish_thing.cur_dir
	fish_thing.sprite.z_index += 1
	fish_thing.grabbed = true

	grabbed = true

	fish_hooked_sound.play()

	cur_fishes = fish_thing

func _on_boat_get_fish() -> void:
	if cur_fishes == null: return

	set_camera_shake.emit(5, .5)
	collected_fishes += 1

	tutorial.visible = false

	if collected_fishes >= max_fishes:
		boat.success_microgame()
		skip_timer.emit()
		win_sound.play()

	cur_fishes.queue_free()
	grabbed = false

	collected_fish_sound.play()

	score.text = str(collected_fishes) + "/" + str(max_fishes) + " FISHES"

func isWinning() -> bool:
	return collected_fishes >= max_fishes

func canSkip() -> bool:
	return boat.failed || boat.win
