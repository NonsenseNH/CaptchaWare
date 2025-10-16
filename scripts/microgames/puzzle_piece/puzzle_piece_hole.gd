extends Node2D

var puzzle_hovering : bool = false
var puzzle_Index : int = 0

@onready var puzzle: Sprite2D = $puzzle

func set_puzzle_texture() -> void:
	puzzle.texture = load("res://sprites/puzzle_piece/masks/puzzle" + str(puzzle_Index) + ".png")
