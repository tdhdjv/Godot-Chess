extends Piece

class_name Pone

@export var promotion_ui:PromotionUI
var dir:Vector2i
var en_passent_victim:bool

signal promoted
signal promotion_chosen(pone:Piece, promote_piece:String)

func create_piece(_board:Board, _is_white:bool, _board_pos:Vector2i):
	super.create_piece(_board, _is_white, _board_pos)
	promotion_ui.promotion_chosen.connect(choose_promotion)
	if is_white:
		dir = Vector2i(0, -1)
	else:
		dir = Vector2i(0, 1)
	
func get_psuedo_moves() -> Array[Move]:
	var moves:Array[Move] = []
	var move_square = board_pos
	
	#marching
	var space = 1
	if not has_moved:
		space = 2
	for i in space:
		move_square += dir
		if not board.in_bound(move_square) or board.board[move_square.x][move_square.y]:
			break
		var move = Move.new(board_pos, move_square, self, null)
		moves.append(move)
		
	#captures
	move_square = board_pos + dir + Vector2i(1, 0)
	if board.in_bound(move_square):
		var occupying_piece = board.board[move_square.x][move_square.y]
		if occupying_piece and occupying_piece.is_white != is_white:
			var move = Move.new(board_pos, move_square, self, occupying_piece)
			moves.append(move)
			
	move_square = board_pos + dir + Vector2i(-1, 0)
	if board.in_bound(move_square):
		var occupying_piece = board.board[move_square.x][move_square.y]
		if occupying_piece and occupying_piece.is_white != is_white:
			var move = Move.new(board_pos, move_square, self, occupying_piece)
			moves.append(move)
	moves.append_array(en_passent_moves())
	return moves
	
func en_passent_moves() -> Array[Move]:
	var moves:Array[Move] = []
	var move_square = board_pos + dir + Vector2i(1, 0)
	var occupying_piece_square = board_pos + Vector2i(1, 0)
	
	if board.in_bound(move_square):
		var occupying_piece = board.board[occupying_piece_square.x][occupying_piece_square.y]
		if occupying_piece and occupying_piece.is_white != is_white and occupying_piece is Pone and occupying_piece.en_passent_victim:
			var move = Move.new(board_pos, move_square, self, occupying_piece)
			moves.append(move)
			
	move_square = board_pos + dir + Vector2i(-1, 0)
	occupying_piece_square = board_pos + Vector2i(-1, 0)
	
	if board.in_bound(move_square):
		var occupying_piece = board.board[occupying_piece_square.x][occupying_piece_square.y]
		if occupying_piece and occupying_piece.is_white != is_white and occupying_piece is Pone and occupying_piece.en_passent_victim:
			var move = Move.new(board_pos, move_square, self, occupying_piece)
			moves.append(move)
	return moves

func move(move:Move):
	super.move(move)
	if move.current_square.y == 0 or move.current_square.y == 7:
		promotion_ui.visible = true
		promoted.emit()
	
func choose_promotion(piece_type:String):
	promotion_chosen.emit(self, piece_type)
	
func undo_move(move:Move):
	super.undo_move(move)
	
