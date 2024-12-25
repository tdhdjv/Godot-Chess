extends VBoxContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	custom_minimum_size.x = size.y
