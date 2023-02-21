extends Node


func _ready():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())


func _input(event):
	
	if event is InputEventMIDI:
		
		print(event)
		if event.controller_number < 50: #assuming cc 1-49 are realtive stepped dials 
			if event.controller_value == 72:
				pass
			if event.controller_value in [1,2,3,8,16]: #relative cc dial, clockwise
				%timeline.value += event.controller_value
			if event.controller_value in [65,66,67,68]:  #relative cc dial, ccw
				%timeline.value -= event.controller_value-64
		else: #assuming 50-127 cc are sliders
			%timeline.value = event.controller_value*0.24
