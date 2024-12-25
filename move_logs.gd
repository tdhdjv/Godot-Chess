extends VBoxContainer

class_name MoveLogs

var index := 1
const move_display := preload("res://ui/move_display/move_display.tscn")

func log_move(move:Move):
	var move_display = move_display.instantiate()
	move_display.set_up(move, index)
	add_child(move_display)
	index += 1
