extends AnimationPlayer

var group = "grabbed"

var is_printing = false
var image:Image = Image.new()

func _ready():
	
	playback_active = true
	play("default") #load the default animation timeline
	pause()


func on_files_dropped(files):
	
	for file in files:
		
		var image = Image.load_from_file(file)
		if not image is Image:
			return #ignore non image files
		
		%onboarding.progress += 1
		
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
		icon.tooltip_text = tooltip
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
	
	#select the image/node( stored in the meta data of each miniature icon in the sidebar
	release_nodes()
	var node = icon.get_meta("node")
	node.add_to_group(group)


func pause():
	%play.button_pressed = false
	stop(false) #pause is the same as stop, just without resetting the time


func record_key(track, key_value):
	
	var animation = get_animation(assigned_animation)
	#var input_value = get_viewport().get_mouse_position()
	time = current_animation_position
	
	for node in get_tree().get_nodes_in_group(group):
		
		var track_path = str(node.name,":",track)
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
func _process(delta):
	
	if Input.is_action_pressed("position"):
		record_key("position", get_viewport().get_mouse_position())
	
	if Input.is_action_pressed("rotation"):
		record_key("rotation", get_viewport().get_mouse_position().x*0.02)
	
	if Input.is_action_pressed("visible"):
		record_key("visible", Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))
	
	if Input.is_action_pressed("scale"):
		record_key("scale", get_viewport().get_mouse_position()*0.01)
	
	if is_playing():
		time = current_animation_position
		%timeline.value = time
		
		if is_printing:
			var frame = %SubViewport.get_texture()
			frame.get_image().save_png( str("user://","potion.",Time.get_date_string_from_system(),".",time,".png") )


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
