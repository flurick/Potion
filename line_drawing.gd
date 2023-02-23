extends Node2D

class Point:
	var line:Line2D
	var idx:int
	var distance:float #used mostly for distance to the mouse cursor
	var position:Vector2
	
	func _to_string():
		if line:
			return str(line.name.replace("@",""),":", idx)
		else:
			return "?"

class Variable:
	var value:Vector2
	var points:Array

class Link:
	var enabled:bool = true
	var position:Vector2
	
	var a:Line2D
	var a_idx:int
	
	var b:Line2D
	var b_idx:int
	
	func _init(a,a_idx, b,b_idx):
		self.position = b.get_point_position(b_idx)
		self.a = a
		self.a_idx = a_idx
		self.b = b
		self.b_idx = b_idx
	
	func _to_string():
		if a and b:
			return "Link(%s %s - %s %s)" %[a.name,a_idx, b.name,b_idx]
		else:
			return "?"


var links = []


func _ready():
	
	for action in InputMap.get_actions().slice(75):
		$"../keys".text += str(action,":", InputMap.action_get_events(action)[0].as_text()[0]," ")



var active_line:Line2D

var grabbed:Point

var hovered:Point
var m:Vector2
var best:Point
func _unhandled_input(event):
	
	
	$"../keys".text = ""
	if grabbed and grabbed.line: $"../keys".text += str(grabbed.line.name,":",grabbed.idx)
	$"../keys".text += " # "
	if hovered and hovered.line: $"../keys".text += str(hovered.line.name,":",hovered.idx)
	
	
	#hover mouse
	if event is InputEventMouseMotion:
		m = event.position
		best = find_best_point(event.position)
		hovered = null
		queue_redraw()
	
	
	#hover mouse to grab
	if event is InputEventMouseMotion and event.is_command_or_control_pressed():
		hovered = find_best_point(event.position)
	
	
	#grab and link points
	if event is InputEventMouseButton and event.is_command_or_control_pressed():
		
		if event.pressed:
			print("grabbing")
			grabbed = find_best_point(event.position)
		
		if not event.pressed:
			if grabbed and hovered:
				if Input.is_key_pressed(KEY_SHIFT):
					remove_links(grabbed.line)
				else:
					add_link()
			grabbed = null
			hovered = null
	
	
	#drag point
	if event is InputEventMouseMotion and event.pressure>0.001 and event.is_command_or_control_pressed():
		
		if grabbed and grabbed.line:
			grabbed.line.set_point_position(grabbed.idx, m)
			set_link(grabbed, m)
	
	
	#draw new lines
	if event is InputEventMouseMotion and not event.is_command_or_control_pressed():
		
		#draw new line
		if !active_line and event.pressure>0.001:
			active_line = Line2D.new()
			active_line.width = 2
			add_child(active_line)
		#terminate if the pen is lifted
		if active_line and event.pressure<0.001:
			active_line = null
		#extend line by continue draggin mouse/pen
		if active_line != null and event.pressure>0.001:
			active_line.add_point(event.position)
	
	
	#replace last drawn line
	if event is InputEventMouseButton and not event.pressed and not event.is_command_or_control_pressed():
		
		active_line = null
		if Input.is_key_pressed(KEY_SHIFT):
			get_child(-2).hide()



func set_link(point:Point, m:Vector2):
	for link in links:
		if link.a == point.line or link.b == point.line:
			link.position = m
	update_linked()



func remove_links(line:Line2D):
	
	for link in links:
		if link.a == line or link.b == line:
			link.enabled = false
	
	update_linked()
	


func find_best_point(position:Vector2, best_distance:float=8):
	
	var best = Point.new()
	for line in get_children():
		
		var idx = 0
		for point in line.points:
			var distance = position.distance_to(line.position + point)
			if distance < best_distance:
				if grabbed and grabbed.line == line \
				and idx == grabbed.idx:
					continue
				best.distance = distance
				best.position = line.position + point
				best.idx = idx
				best.line = line
			idx += 1
		
	return best



func add_link():
	
	if grabbed.line and hovered.line:
		print("line == ", grabbed.line == hovered.line)
		print("idx == ", grabbed.idx == hovered.idx)
		var newlink = Link.new(grabbed.line,grabbed.idx, hovered.line,hovered.idx)
		
		for link in links:

#			if grabbed.line == hovered.line:
#				print("skip self linking ", newlink)
#				return

			if (newlink.a == link.a and newlink.b == link.b) \
			or (newlink.a == link.b and newlink.b == link.a):

				if (newlink.a_idx == link.a_idx and newlink.b_idx == link.b_idx) \
				or (newlink.a_idx == link.b_idx and newlink.b_idx == link.a_idx):
					print("skip duplicate linking ", newlink)
					return
		
		print("adding link ", newlink)
		links.append(newlink)
	
	update_linked()




func update_linked():
	
	
#	for i in links.size():
#		if not links[i].enabled:
#			links.remove_at(i)
	
	for link in links:
		if link.enabled:
			link.a.set_point_position(link.a_idx, link.position)
			link.b.set_point_position(link.b_idx, link.position)
	
	
	# update the ui list of links
	
	for button in $"../PanelContainer/VBoxContainer".get_children():
		button.queue_free()
	
	for link in links:
		if link.enabled and link.a and link.b:
			var the_button = Button.new()
			the_button.set("theme_override_font_sizes/font_size", 11) 
			the_button.text = str(link.a.name,":",link.a_idx," - ",link.b.name,":",link.b_idx ).replace("@","")
			$"../PanelContainer/VBoxContainer".add_child(the_button)


var default_font = SystemFont.new()
func _draw():
	if hovered and hovered.line:
		draw_circle(hovered.position, 3, Color.WHITE)
		draw_string(default_font, hovered.position-Vector2(0,16), str(hovered.idx,"/",hovered.line.get_point_count()), HORIZONTAL_ALIGNMENT_CENTER, -1, 10 )
