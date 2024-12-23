extends Piece

class_name King

const dirs = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var can_castle_king:bool = true
var can_castle_queen:bool = true

func get_psuedo_moves() -> Array[Move]:
	var moves:Array[Move] = []
	for dir in dirs:
		var move_square = board_pos+dir
		if not board.in_bound(move_square):
			continue
		var occupying_piece = board.board[move_square.x][move_square.y]
		
		if occupying_piece and occupying_piece.is_white == is_white:
			continue
		
		moves.append(Move.new(board_pos, move_square, self, occupying_piece))
		
	return moves
	
func get_moves() -> Array[Move]:
	var all_moves = get_psuedo_moves()
	all_moves.append_array(get_castle_moves())
	return all_moves.filter(filter_illegal_moves)

func get_castle_moves() -> Array[Move]:
	var moves:Array[Move] = []
	if has_moved:
		return moves
	
	#king side
	var king_side_rook = board.board[7][board_pos.y]
	var can_castle = true
	#check if the rook can see the king
	for i in range(board_pos.x+1, 7):
		var piece = board.board[i][board_pos.y]
		if piece:
			can_castle = false
	#check if the king walks though a check
	var occupying_piece = board.board[board_pos.x+1][board_pos.y]
	var non_move = Move.new(board_pos, board_pos+Vector2i(1, 0), self, occupying_piece)
	if board.move_leads_to_check(non_move):
		can_castle = false
			
	can_castle = can_castle and king_side_rook is Rook and not king_side_rook.has_moved and can_castle_king
	if can_castle:
		moves.append(Move.new(board_pos, board_pos+Vector2i(2, 0), self, null))
	
	#queen side
	var queen_side_rook = board.board[0][board_pos.y]
	can_castle = true
	#check if the rook can see the king
	for i in range(1, board_pos.x):
		var piece = board.board[i][board_pos.y]
		if piece:
			can_castle = false
		
	occupying_piece = board.board[board_pos.x-1][board_pos.y]
	non_move = Move.new(board_pos, board_pos-Vector2i(1, 0), self, occupying_piece)
	if board.move_leads_to_check(non_move):
		can_castle = false
		
	can_castle = can_castle and queen_side_rook is Rook and not queen_side_rook.has_moved and can_castle_queen
	if can_castle:
		moves.append(Move.new(board_pos, board_pos-Vector2i(2, 0), self, null))

	return moves

func ghost_move(move:Move):
	#castling move (special case)
	if abs(move.current_square.x-board_pos.x) == 2:
		var rook:Rook
		var rook_square:Vector2i
		#king side
		if move.current_square.x == 6:
			rook = board.board[7][board_pos.y]
			rook_square = Vector2i(5, board_pos.y)
		#queen side
		if move.current_square.x == 2:
			rook = board.board[0][board_pos.y]
			rook_square = Vector2i(3, board_pos.y)
		board.move(Move.new(rook.board_pos, rook_square, rook, null))
	super.ghost_move(move)
	
func ghost_undo_move(move:Move):
	#undoing castling move (special case)
	if abs(move.current_square.x-move.previous_square.x) == 2:
		var rook:Rook
		var previous_rook_square:Vector2i
		#king side
		if move.current_square.x == 6:
			rook = board.board[5][board_pos.y]
			previous_rook_square = Vector2i(7, board_pos.y)
		#queen side
		if move.current_square.x == 2:
			rook = board.board[3][board_pos.y]
			previous_rook_square = Vector2i(0, board_pos.y)
		board.undo_move(Move.new(previous_rook_square, rook.board_pos, rook, null))
	super.ghost_undo_move(move)
