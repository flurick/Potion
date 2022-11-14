extends Control


var progress = 0: set = _set_progress
func _set_progress(value):
	if value > get_child_count():
		progress = 99
	else:
		progress = value
	_show()


func _ready():
	_show()


func _show():
	for n in get_child_count():
		get_child(n).hide()
		if n == progress:
			get_child(n).show()
