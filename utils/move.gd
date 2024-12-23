extends Node

class_name Move

var previous_square:Vector2i
var current_square:Vector2i
var moved_piece:Piece
var captured_piece:Piece

func _init(_previous_square:Vector2i, _current_square:Vector2i, _moved_piece:Piece, _captured_piece:Piece):
	previous_square = _previous_square
	current_square = _current_square
	captured_piece = _captured_piece
	moved_piece = _moved_piece
