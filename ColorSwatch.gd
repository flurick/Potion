extends ColorRect


func _on_gui_input(event):
	
	if event is InputEventMouseButton:
		
		if not event.pressed:
			%fg.color = color


func _can_drop_data(at_position, data):
	return data is Color
func _drop_data(at_position, data):
	color = data
