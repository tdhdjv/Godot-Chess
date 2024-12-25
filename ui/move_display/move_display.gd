extends Control

class_name MoveDisplay

@export var move_label:Label
@export var number_label:Label

var move:Move
var index:int

func set_up(_move:Move, _index:int) -> void:
	move = _move
	index = _index
	
func _ready() -> void:
	move_label.text = move_to_string(move)
	number_label.text = str(index)
	
func move_to_string(move:Move):
	var piece_char = ''
	var piece = move.moved_piece
	if piece is Knight:
		piece_char = 'N'
	if piece is Bishop:
		piece_char = 'B'
	if piece is Rook:
		piece_char = 'R'
	if piece is Queen:
		piece_char = 'Q'
	if piece is King:
		piece_char = 'K'
	var file = String.chr(move.current_square.x+'a'.to_ascii_buffer()[0])
	var rank = 8-move.current_square.y
	return piece_char + file + str(rank)
