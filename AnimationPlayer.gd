extends AnimationPlayer

var group = "grabbed"

var is_printing = false
var image:Image = Image.new()


func _ready():
	
	playback_active = true
	play("default") #load the default animation timeline
	pause()


func on_files_dropped(files):
	
	%onboarding.progress += 1
	
	for file in files:
		
		var image = Image.load_from_file(file)
		if not image is Image:
			return #ignore non image files
		
		#load a file into a godot sprite
		var texture = ImageTexture.create_from_image(image)
		var sprite = Sprite2D.new()
		sprite.texture = texture
		get_parent().add_child(sprite)
		add_icon(sprite, file, texture)


func add_icon(node, tooltip, icon_texture=null):
		
		#add an icon for selecting ui selection
		#var icon:Button = Button.new()
		var icon:Button = load("res://icon_template.tscn").instantiate()
		#icon.text = str(get_child_count())
		icon.set_meta("node", node)
		icon.pressed.connect(icon_pressed.bind(icon))
		#
		icon.tooltip_text = str(tooltip, "\n", "Alt click to parent")
		if icon_texture:
			icon.icon = icon_texture
		%Drawings/v.add_child(icon)
		
		release_nodes()
		
		#grab the new node
		icon.button_pressed = true
		node.add_to_group(group)
		var window = Window.new()
		window.grab_focus()


func release_nodes():
	
	for n in get_tree().get_nodes_in_group(group):
		n.remove_from_group(group)


func icon_pressed(icon:Button):
	
	if Input.is_key_pressed(KEY_ALT):
		var animation:Animation = get_animation(assigned_animation)
		for n in get_tree().get_nodes_in_group(group):
			var old_path = n.get_path()
			var new_path = adopt(n, icon.get_meta("node")).get_path()
			while animation.find_track(old_path, Animation.TYPE_VALUE) != -1:
				animation.track_set_path( animation.find_track(old_path, Animation.TYPE_VALUE), new_path)
	else:
		release_nodes()
		
	#select the image/node( stored in the meta data of each miniature icon in the sidebar
	var node = icon.get_meta("node")
	node.add_to_group(group)


func adopt(node, new_parent):
	if node.get_parent():
		node.get_parent().remove_child(node)
	new_parent.add_child(node)
	return node


func pause():
	%play.button_pressed = false
	stop(false) #pause is the same as stop, just without resetting the time


func record_key(node, track, key_value):
	
	%onboarding.progress += 1
	
	var animation = get_animation(assigned_animation)
	#var input_value = get_viewport().get_mouse_position()
	time = current_animation_position
	
		
	var track_path = str(%SubViewport.get_path_to(node),":",track)
	#if track=="scale" and node is LineEdit:
		#track_path = str(node.name,":","theme_override_font_sizes/font_size")
		
	if animation:
		var track_idx = animation.find_track(track_path, Animation.TYPE_VALUE)
		if track_idx == -FAILED:
			track_idx = animation.add_track(Animation.TYPE_VALUE, 0)
			animation.track_set_path(track_idx, track_path)
		animation.track_insert_key(track_idx, time, key_value)
		seek(time, true)


var time = 0 #using "time" to sync the slider in the ui and the animationplayer
var m:Vector2
var m_offset:Vector2
var click:bool
func _process(delta):
	
	m = get_viewport().get_mouse_position()
	click = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if Input.is_action_pressed("position"):
		for node in get_tree().get_nodes_in_group(group):
			record_key(node, "position", m)
	
	if Input.is_action_pressed("rotation"):	
		for node in get_tree().get_nodes_in_group(group):
			record_key(node, "rotation", m.x*0.02)
	
	if Input.is_action_pressed("visible"):
		for node in get_tree().get_nodes_in_group(group):
			record_key(node, "visible", click)
	
	if Input.is_action_pressed("scale"):
		for node in get_tree().get_nodes_in_group(group):
			record_key(node, "scale", m*0.01)
	
	if is_playing():
		time = current_animation_position
		%timeline.value = time
		
		if is_printing:
			var frame = %SubViewport.get_texture()
			frame.get_image().save_png( str("user://","potion.",Time.get_date_string_from_system(),".",int(time*100),".png") )


func _input(event):
	
	if event.is_action("ui_page_up"):
		var node = get_tree().get_first_node_in_group(group)
		get_parent().move_child(node, node.get_index()-1 )
	if event.is_action("ui_page_down"):
		var node = get_tree().get_first_node_in_group(group)
		get_parent().move_child(node, node.get_index()+1 )
	
	if event.is_action("ui_home"):
		seek_home()
	if event.is_action("ui_end"):
		seek_end()


func _on_play_toggled(button_pressed):
	if button_pressed: play()
	else: pause()


func _on_timeline_drag_ended(value_changed):
	#not sure why we can update the timeline value from here?
	#you might think we needed to use seek(), and set the value indirectly that way
	pause()
	#seek(value_changed, %timeline.value)
#	print(current_animation_position, %timeline.value)


func _on_animation_finished(anim_name):
	pause()


func seek_home():
	#%timeline.value = 0
	seek(0, true)
	pause()


func seek_end():
	#seek(get_animation(assigned_animation).length, true)
	%timeline.value = %timeline.max_value


func _on_timeline_value_changed(value):
	seek(value, true)


func _on_print_button_toggled(button_pressed):
	is_printing = button_pressed


func _on_no_pos_pressed():
	
	var animation = get_animation(assigned_animation)
	
	for node in get_tree().get_nodes_in_group(group):
		var track_path = str(node.name,":","position")
		var track_idx = animation.find_track(track_path, Animation.TYPE_VALUE)
		if track_idx != -FAILED:
			animation.remove_track(track_idx)


func _on_no_vis_pressed():
	
	var animation = get_animation(assigned_animation)
	
	for node in get_tree().get_nodes_in_group(group):
		var track_path = str(node.name,":","visible")
		var track_idx = animation.find_track(track_path, Animation.TYPE_VALUE)
		if track_idx != -FAILED:
			animation.remove_track(track_idx)


func _on_no_rot_pressed():
	
	var animation = get_animation(assigned_animation)
	
	for node in get_tree().get_nodes_in_group(group):
		var track_path = str(node.name,":","rotation")
		var track_idx = animation.find_track(track_path, Animation.TYPE_VALUE)
		if track_idx != -FAILED:
			animation.remove_track(track_idx)


func _on_add_pressed():
	
	#add a new label and its icon to the scene
	var label = LineEdit.new()
	label.expand_to_text_length = true
	label.text = "potion" 
	label.flat = true 
	label.position = get_viewport().size * 0.5
	get_parent().add_child(label)
	add_icon(label, str("Label ", get_parent().get_child_count()) )


func _on_no_scale_pressed():
	
	var animation = get_animation(assigned_animation)
	
	for node in get_tree().get_nodes_in_group(group):
		var track_path = str(node.name,":","scale")
		var track_idx = animation.find_track(track_path, Animation.TYPE_VALUE)
		if track_idx != -FAILED:
			animation.remove_track(track_idx)
