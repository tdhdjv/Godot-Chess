extends Piece

class_name Knight

const dirs = [Vector2i(-1,2),Vector2i(1,2),Vector2i(-1,-2),Vector2i(1,-2),Vector2i(2,1),Vector2i(2,-1),Vector2i(-2,1),Vector2i(-2,-1)]

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
