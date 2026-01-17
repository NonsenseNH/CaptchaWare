extends Sprite2D

class_name cactus

var speed_set := 800.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = randi_range(0, hframes - 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if speed_set == 0: return
	position += (Vector2.LEFT * speed_set) * delta
