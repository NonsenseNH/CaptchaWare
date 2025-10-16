extends Microgame

const PUZZLE_PIECE_HOLE = preload("res://instances/PuzzlePiece/puzzle_piece_hole.tscn")
const PUZZLE_PIECE = preload("res://instances/PuzzlePiece/puzzle_piece.tscn")
const PUZZLE_PIECE_MASK_LOCATION : String = "res://sprites/puzzle_piece/"

@onready var mask_game: ColorRect = $mask
@onready var holes_group: Node2D = $mask/holes
@onready var image_rect: TextureRect = $TextureRect
@onready var puzzle_spawns: HBoxContainer = $puzzle_spawns

var spawn_locations : Array[Vector2]

var puzzle_piece_shape_index_pool : Array[int] = []

var cur_puzzle_amount := 0
var puzzles_placed := 0

var random_puzzle_positions : Dictionary = {
	1 : [
			[[60.0,353.0],[59.0,337.0]],
		],
	2 : [
			[[60.0,353.0],[59.0,337.0]]
		],
	3 : [
			[[60.0,353.0],[59.0,156.0]],
			[[60.0,353.0],[293.0,337.0]]
		],
	4 : [
			[[60.0,136.0],[59.0,156.0]],
			[[60.0,136.0],[293.0,337.0]],
			[[246.0,353.0],[59.0,337.0]]
		]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for spawns in puzzle_spawns.get_children():
		spawn_locations.append(spawns.global_position)
	match difficulty:
		1, 2:
			set_puzzle_pieces(1)
		3:
			set_puzzle_pieces(2)
		4:
			set_puzzle_pieces(3)

func set_puzzle_pieces(puzzle_amount: int) -> void:
	var image_array : Array = get_file_list(PUZZLE_PIECE_MASK_LOCATION)
	image_rect.texture = load("res://sprites/puzzle_piece/" + image_array.pick_random())
	cur_puzzle_amount = puzzle_amount
	
	var rand_puzzle_pos : Array = random_puzzle_positions[difficulty]
	rand_puzzle_pos.shuffle()
	
	for i in range(puzzle_amount):
		var puzzle_index := get_unique_puzzle_index()
		var puzzle := PUZZLE_PIECE.instantiate()
		var puzzlehole := PUZZLE_PIECE_HOLE.instantiate()
		
		
		var random_puzzle_pos : Vector2 = Vector2(
			randf_range(rand_puzzle_pos[i][0][0],rand_puzzle_pos[i][0][1]),
			randf_range(rand_puzzle_pos[i][1][0],rand_puzzle_pos[i][1][1])
			)
		
		mask_game.add_child(puzzle)
		holes_group.add_child(puzzlehole)
		
		puzzle.count_puzzles.connect(count_puzzles)
		puzzle.set_puzzle_texture(puzzle_index, image_rect.texture, random_puzzle_pos)
		puzzle.global_position = spawn_locations[i]
		puzzle.cur_puzzle_hole = puzzlehole
		
		puzzlehole.position = random_puzzle_pos + Vector2(0,-22) #offset
		puzzlehole.puzzle_Index = puzzle_index
		puzzlehole.set_puzzle_texture()

func get_unique_puzzle_index() -> int:
	var cur_index : int
	while true:
		cur_index = randi_range(0,8)
		
		if puzzle_piece_shape_index_pool.has(cur_index): continue
		puzzle_piece_shape_index_pool.append(cur_index)
		break
	
	return cur_index

func count_puzzles() -> void:
	puzzles_placed += 1
	if cur_puzzle_amount == puzzles_placed: 
		skip_timer.emit()
		finished = true

func isWinning() -> bool:
	super.isWinning()
	return finished
