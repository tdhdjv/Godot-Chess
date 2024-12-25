extends Panel

class_name GameAction

@export var game_over:HBoxContainer
@export var playing: Button
@export var label:Label

signal resigned

func change_to_playing(is_white_turn:bool):
	var turn_text = 'White Turn'
	if not is_white_turn:
		turn_text = 'Black Turn'
	
	label.text = turn_text
	game_over.visible = false
	playing.visible = true
	
func change_to_over(is_winner_white:bool):
	var win_text = 'WHITE WON'
	if not is_winner_white:
		win_text = 'BLACK WON'
	
	label.text = win_text
	game_over.visible = true
	playing.visible = false
	
func _on_button_pressed() -> void:
	resigned.emit()

func _on_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_button_3_button_down() -> void:
	get_tree().change_scene_to_file("res://ui/main_screen/main_screen.tscn")
