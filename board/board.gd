extends Panel

class_name Board 

@export var white_color:Color
@export var black_color:Color

@export var white_pieces:Node
@export var black_pieces:Node

const PONE_SCENE = preload('res://pieces/pone/pone.tscn')
const KNIGHT_SCENE = preload('res://pieces/knight/knight.tscn')
const BISHOP_SCENE = preload('res://pieces/bishop/bishop.tscn')
const ROOK_SCENE = preload('res://pieces/rook/rook.tscn')
const QUEEN_SCENE = preload('res://pieces/queen/queen.tscn')
const KING_SCENE = preload('res://pieces/king/king.tscn')

const LETTER_TO_PIECE := {'p': PONE_SCENE, 'n': KNIGHT_SCENE, 'b':BISHOP_SCENE, 'r': ROOK_SCENE, 'q': QUEEN_SCENE, 'k': KING_SCENE} 
const START_FEN:String = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR'

var highlighted_squares:Dictionary = {}
var square_length:float
var square_size:Vector2

var pieces:Array[Piece] = []
var board := []

var last_moved_piece:Piece

var white_king:King
var black_king:King
var pones:Array[Pone] = []

func _ready() -> void:
	for i in 8:
		var row = []
		for j in 8:
			row.append(null)
		board.append(row)

func promote(pone:Pone, promoted_piece:String):
	add_piece(pone.is_white, pone.board_pos, promoted_piece)
	remove_piece(pone)

func add_piece(is_white:bool, board_pos:Vector2i, piece_type:String) -> void:
	var piece_scene:PackedScene = LETTER_TO_PIECE[piece_type]
	var piece:Piece = piece_scene.instantiate()
	
	#if king
	if piece_type == 'k':
		if is_white:
			white_king = piece
		else:
			black_king = piece
	if piece_type == 'p':
		pones.append(piece)
	
	piece.create_piece(self, is_white, board_pos)
	pieces.append(piece)
	snap_piece_to_square(piece)
	
	board[board_pos.x][board_pos.y] = piece
	
	if piece.is_white:
		white_pieces.add_child(piece)
	else:
		black_pieces.add_child(piece)

func decode_fen(fen:String):
	var x = 0
	var y = 0
	for char in fen:
		#number
		if char.is_valid_int():
			x += int(char)
		#slash
		elif char == '/':
			y += 1
			x = 0
		#alphabet
		else:
			var is_white = char.to_upper() == char
			add_piece(is_white, Vector2i(x, y), char.to_lower())
			x += 1

func _draw() -> void:
	for i in 8:
		for j in 8:
			var is_white = (i+j)%2 == 0
			var color = white_color if is_white else black_color
			var pos = Vector2(i, j)*square_length
			var rect = Rect2(pos, square_size)
			draw_rect(rect, color)
			
	for highlight in highlighted_squares:
		var color = highlighted_squares[highlight]
		var pos = highlight*square_length
		var rect = Rect2(pos, square_size)
		draw_rect(rect, color)

func _on_resized() -> void:
	#make sure that the square_lengths are in the correct
	square_length = size.y/8
	square_size = Vector2(1, 1)*square_length
	
	#change the sprite's size/position of all the pieces to match the board
	for piece in pieces:
		snap_piece_to_square(piece)
	
func board_to_world_pos(board_pos:Vector2i) -> Vector2:
	var world_pos:Vector2 = (Vector2(board_pos)+Vector2(0.5, 0.5)) * square_length + global_position
	return world_pos

func world_to_board_pos(world_pos:Vector2) -> Vector2i:
	var board_pos:Vector2i = Vector2i((world_pos - global_position)/square_length)
	return board_pos

func in_bound(board_pos:Vector2i) -> bool:
	return 0 <= board_pos.x and board_pos.x < len(board) and 0 <= board_pos.y and board_pos.y < len(board[0])

func snap_piece_to_square(piece:Piece) -> void:
	var new_piece_pos:Vector2i = board_to_world_pos(piece.board_pos)
	var new_piece_scale:Vector2 = square_size/piece.texture.get_size().y
	piece.scale = new_piece_scale
	piece.global_position = new_piece_pos
	
func ghost_move(move:Move) -> void:
	#move the the piece
	var previous_square = move.previous_square
	var current_square = move.current_square
	var piece = move.moved_piece
	piece.ghost_move(move)
	board[previous_square.x][previous_square.y] = null
	board[current_square.x][current_square.y] = piece
		
	var captured_piece = move.captured_piece
	if captured_piece:
		captured_piece.capture()
		remove_piece(captured_piece)
		
func ghost_undo_move(move:Move) -> void:
	var piece = move.moved_piece
	var captured_piece = move.captured_piece
	var previous_square = move.previous_square
	var current_square = move.current_square
	
	board[previous_square.x][previous_square.y] = piece
	board[current_square.x][current_square.y] = null
	
	piece.ghost_undo_move(move)
	
	#un capture the piece
	if captured_piece:
		board[captured_piece.board_pos.x][captured_piece.board_pos.y] = captured_piece
		if captured_piece.is_white:
			white_pieces.add_child(captured_piece)
		else:
			black_pieces.add_child(captured_piece)
		board[captured_piece.board_pos.x][captured_piece.board_pos.y] = captured_piece
	
func move(move:Move) -> void:
	#move the the piece
	var previous_square = move.previous_square
	var current_square = move.current_square
	var piece = move.moved_piece
	piece.move(move)
	board[previous_square.x][previous_square.y] = null
	board[current_square.x][current_square.y] = piece
	
	#capture the piece
	var captured_piece = move.captured_piece
	if captured_piece:
		captured_piece.capture()
		remove_piece(captured_piece)
	
	#set the piece global position
	snap_piece_to_square(piece)

func undo_move(move:Move) -> void:
	var piece = move.moved_piece
	var captured_piece = move.captured_piece
	var previous_square = move.previous_square
	var current_square = move.current_square
	
	board[previous_square.x][previous_square.y] = piece
	board[current_square.x][current_square.y] = null
	
	piece.undo_move(move)
	
	#un capture the piece
	if captured_piece:
		pieces.append(captured_piece)
		if captured_piece.is_white:
			white_pieces.add_child(captured_piece)
		else:
			black_pieces.add_child(captured_piece)
		board[captured_piece.board_pos.x][captured_piece.board_pos.y] = captured_piece
		snap_piece_to_square(captured_piece)
	
	#set the piece global position
	snap_piece_to_square(piece)

func move_leads_to_check(move:Move):
	ghost_move(move)
	var leads_to_check = is_check(move.moved_piece.is_white)
	ghost_undo_move(move)
	return leads_to_check
	
func is_check(is_white:bool):
	var players_king = white_king
	var opponent_pieces = black_pieces
	
	if not is_white:
		players_king = black_king
		opponent_pieces = white_pieces
		
	var opponents_moves = []
	for opponent_piece in opponent_pieces.get_children():
		#if the move attacks the king
		for move in opponent_piece.get_psuedo_moves():
			if move.captured_piece == players_king:
				return true
	return false
	
func is_check_mate(is_white:bool):
	var players_pieces = white_pieces
	
	if not is_white:
		players_pieces = black_pieces
		
	for piece in players_pieces.get_children():
		if piece.get_moves():
			return false
	return true
	
func highlight_square(square:Vector2i, highlight_color:Color, override=true) -> void:
	if not override and highlighted_squares.has(square):
		return
	highlighted_squares[square] = highlight_color
	queue_redraw()
	
func unhighlight_square(square:Vector2i) -> void:
	highlighted_squares.erase(square)
	queue_redraw()

func remove_piece(piece:Piece) -> void:
	pieces.erase(piece)
	
	var is_white = piece.is_white
	if is_white:
		white_pieces.remove_child(piece)
	else:
		black_pieces.remove_child(piece)
		
	#if there is a piece on board remove it
	var board_pos = piece.board_pos
	if board[board_pos.x][board_pos.y] == piece:
		board[board_pos.x][board_pos.y] = null
