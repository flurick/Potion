extends Node2D


func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)
	print(curve)


func on_files_dropped(files):
	
	var image = Image.load_from_file(files[0])
	var texture = ImageTexture.create_from_image(image)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	add_child(sprite)


var curve:Curve2D = Curve2D.new()
var is_recording = false
func _on_button_toggled(pressed):
	if pressed:
		is_recording = true
		curve = Curve2D.new()
	else:
		stop_recording()


var time = 0
func _process(delta):
	
	if is_recording:
		curve.add_point(get_viewport().get_mouse_position())
		time += delta
		$"../Panel/HBoxContainer/timeline".value = time
		if time >= $"../Panel/HBoxContainer/timeline".max_value:
			stop_recording()
			$"../Panel/HBoxContainer/timeline".value = $"../Panel/HBoxContainer/timeline".max_value

func stop_recording():
	is_recording = false
	print("stopped recording", Time.get_ticks_msec())
	
	var new_path = Path2D.new()
	new_path.curve = curve
	add_child(new_path)
	
	var new_follow = PathFollow2D.new()
	new_path.add_child(new_follow)
	
	for node in get_tree().get_nodes_in_group("grabbed"):
		if node:
			adopt(node, new_follow)

func adopt(node, new_parent):
	if node.get_parent():
		node.get_parent().remove_child(node)
	new_parent.add_child(node)
	


func _on_timeline_value_changed(value):
	time = value
	
	for path in get_children():
		for follow in path.get_children():
			follow.progress_ratio = time*0.01
