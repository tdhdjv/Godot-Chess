extends Node

@export var board:Board
@export var white_timer:TimerUI
@export var black_timer:TimerUI
@export var move_logs:Node
@export var fade_color:Color
@export var selected_color:Color
@export var mouse_square_color:Color
@export var legal_moves_color:Color

var selected_piece:Piece
var selected_square:Vector2i
var is_white_turn:bool
var chosing_promotion:bool
var previous_move:Move

const start_fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

func _ready() -> void:
	decode_fen(start_fen)
	for pone in board.pones:
		pone.promoted.connect(transtition_to_promote_state)
		pone.promotion_chosen.connect(promote)
	white_timer.activate()
	
func decode_fen(fen:String):
	var board_data = fen.split(' ')
	board.decode_fen(board_data[0])
	if board_data[1] == 'w':
		is_white_turn = true
	else:
		is_white_turn = false
		
	if 'K' not in board_data[2]:
		board.white_king.can_castle_king = false
	if 'k' not in board_data[2]:
		board.black_king.can_castle_king = false
	if 'Q' not in board_data[2]:
		board.white_king.can_castle_queen = false
	if 'q' not in board_data[2]:
		board.black_king.can_castle_queen = false

func _process(delta: float) -> void:
	if chosing_promotion:
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_square := board.world_to_board_pos(mouse_pos)
	if Input.is_action_just_pressed("left_click") and board.in_bound(mouse_square):
		#mouse press
		select_square(mouse_square)
					
	if Input.is_action_just_released('left_click'):
		if selected_piece:
			board.snap_piece_to_square(selected_piece)
		if selected_piece and mouse_square != selected_square:
			unhighlight()
			for move in selected_piece.get_moves():
				if move.current_square == mouse_square:
					board.move(move)
					#en passent
					if move.moved_piece is Pone and abs(move.current_square.y-move.previous_square.y) == 2:
						move.moved_piece.en_passent_victim = true
					if previous_move and previous_move.moved_piece is Pone:
						previous_move.moved_piece.en_passent_victim = false
					move_logs.add_child(move)
					previous_move = move
					is_white_turn = not is_white_turn
					if is_white_turn:
						white_timer.activate()
						black_timer.deactivate()
					else:
						white_timer.deactivate()
						black_timer.activate()
					print(board.is_check_mate(is_white_turn))
			selected_piece = null
	
	if Input.is_action_pressed("left_click"):
		if selected_piece:
			selected_piece.global_position = mouse_pos
	
	if Input.is_action_just_pressed("ui_accept"):
		board.undo_move(previous_move)
	
func select_square(square:Vector2i):
	var new_selected_piece = board.board[square.x][square.y]
	if new_selected_piece == null or new_selected_piece.is_white != is_white_turn:
		return
	unhighlight()
	selected_square = square
	selected_piece = new_selected_piece
	
	#highlights
	board.highlight_square(selected_square, selected_color)
	for move in selected_piece.get_moves():
		board.highlight_square(move.current_square, legal_moves_color)
		
func unhighlight():
	board.unhighlight_square(selected_square)
	selected_square = Vector2i(-1,-1)
	if selected_piece:
		for move in selected_piece.get_moves():
			board.unhighlight_square(move.current_square)

func transtition_to_promote_state():
	chosing_promotion = true
	for i in 8:
		for j in 8:
			board.highlight_square(Vector2i(i, j),fade_color)

func promote(pone:Pone, piece_type:String):
	board.promote(pone, piece_type)
	chosing_promotion = false
	for i in 8:
		for j in 8:
			board.unhighlight_square(Vector2i(i, j))
