extends Panel

class_name TimerUI

var active:bool
var time_left:float
@export var label:Label

func _ready() -> void:
	time_left = 10*60

func activate():
	active = true
	
func deactivate():
	active = false

func _process(delta: float) -> void:
	if active:
		time_left -= delta
		var minutes = time_left / 60
		var seconds = fmod(time_left, 60)
		label.text = '%d:%02d' % [minutes, seconds]
