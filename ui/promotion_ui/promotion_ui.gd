extends Control

class_name PromotionUI

var is_white = true

@onready var black_ui = $PanelContainer/MarginContainer/BlackUI
@onready var white_ui = $PanelContainer/MarginContainer/WhiteUI

signal promotion_chosen(piece_type:String)

func _ready():
	set_white(true)

func set_white(white:bool):
	is_white = white
	if is_white:
		white_ui.visible = true
		black_ui.visible = false
	else:
		white_ui.visible = false
		black_ui.visible = true

func _on_knight_button_button_down():
	promotion_chosen.emit('n')
	
func _on_bishop_button_button_down():
	promotion_chosen.emit('b')

func _on_rook_button_button_down():
	promotion_chosen.emit('r')

func _on_queen_button_button_down():
	promotion_chosen.emit('q')
