extends Sprite2D

class_name Piece

@export var black_image:Texture2D
@export var white_image:Texture2D

var board:Board
var board_pos:Vector2i
var is_white:bool
var previous_has_moved:bool
var has_moved:bool
var last_moved:bool

func create_piece(_board:Board, _is_white:bool, _board_pos:Vector2i):
	board = _board
	is_white = _is_white
	board_pos = _board_pos
	
	if not is_white:
		texture = black_image
	
func ghost_move(move:Move):
	board_pos = move.current_square
	
func ghost_undo_move(move:Move):
	board_pos = move.previous_square
	
func move(move:Move):
	previous_has_moved = has_moved
	has_moved = true
	ghost_move(move)
	
func undo_move(move:Move):
	has_moved = previous_has_moved
	ghost_undo_move(move)
	
	
func capture():
	pass
	
func get_psuedo_moves() -> Array[Move]:
	assert('Not implemented yet!')
	return []
		
func get_moves() -> Array[Move]:
	return get_psuedo_moves().filter(filter_illegal_moves)
	
func filter_illegal_moves(move:Move):
	return not board.move_leads_to_check(move)
