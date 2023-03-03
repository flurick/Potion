extends ColorPickerButton

func _get_drag_data(position):
	set_drag_preview(self) 
	return color
