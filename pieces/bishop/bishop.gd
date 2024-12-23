extends Piece

class_name Bishop

const dirs = [Vector2i(-1,1),Vector2i(-1,-1),Vector2i(1,1),Vector2i(1,-1)]

func get_psuedo_moves() -> Array[Move]:
	var moves:Array[Move] = []
	for dir in dirs:
		var move_square = board_pos
		while true:
			move_square += dir
			if not board.in_bound(move_square):
				break
			var occupying_piece = board.board[move_square.x][move_square.y]
			var move := Move.new(board_pos, move_square, self, occupying_piece)
			
			if occupying_piece:
				if occupying_piece.is_white != is_white:
					moves.append(move)
				break
			moves.append(move)
	return moves
