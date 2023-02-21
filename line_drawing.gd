extends Node2D

class Link:
	var a:Line2D
	var a_idx:int
	var b:Line2D
	var b_idx
	func _init(a,a_idx, b,b_idx):
		self.a = a
		self.a_idx = a_idx
		self.b = b
		self.b_idx = b_idx
	func _to_string():
		if a and b:
			return "Link(%s:%s-%s:%s)" %[a.name,a_idx, b.name,b_idx]

var links = []

func _ready():
	for action in InputMap.get_actions().slice(75):
		$"../keys".text += str(action,":", InputMap.action_get_events(action)[0].as_text()[0]," ")

var current_line:Line2D
var active_idx:int
var hover_pos:Vector2
var m:Vector2
func _unhandled_input(event):

	if current_line:
		$"../RichTextLabel".text = str("Current:",current_line.name,":",active_idx,"\n", links).replace("@","")


	if event is InputEventMouseMotion:
		m = event.position
		hover_pos = find_best_point(event.position, false).point
		queue_redraw()
	
	
	if Input.is_action_pressed("draw"):
		
		if event is InputEventMouseButton:
			current_line = Line2D.new()
			current_line.width = 2
			add_child(current_line)
		
		elif event is InputEventMouseMotion:
			if event.pressure and current_line != null:
				current_line.add_point(event.position)
	
	
	if Input.is_action_just_pressed("vertex"):
		var best = find_best_point(m,false)
		current_line = best.line
		active_idx = best.idx
	if Input.is_action_pressed("vertex"):
		if event is InputEventMouseMotion:
			if current_line and current_line.get_point_count()>active_idx:
				current_line.set_point_position(active_idx, m)
				update_linked()
	if Input.is_action_just_released("vertex"):
				update_linked()
	
	
	if Input.is_action_just_pressed("link"):
		var best = find_best_point(m)
		current_line.set_point_position(active_idx, best.point)
	if Input.is_action_just_released("link"):
		add_link(m)


func find_best_point(position:Vector2, exlude_active=true, best_distance:float=24):
	
	var best_line:Line2D
	var best_point_index:int
	var best_point:Vector2
	for line in get_children():
		var idx = 0
		for point in line.points:
			var distance = position.distance_to(line.position + point)
			if distance < best_distance:
				if exlude_active and line==current_line and idx==active_idx:
					continue
				best_distance = distance
				best_line = line
				best_point_index = idx
				best_point = line.position + point
			idx += 1
	return {"line":best_line,"idx":best_point_index,"distance":best_distance,"point":best_point}


func add_link(mouse_position):
	
	var best = find_best_point(mouse_position,true)
	if best.line != null:
		print("adding link")
		var new_link = Link.new(current_line,active_idx, best.line,best.idx)
		
		#alternative: if links.has(new_link): return
		for link in links:
			if new_link.a == link.a and new_link.a_idx == link.a_idx \
			and new_link.b == link.b and new_link.b_idx == link.b_idx:
				print("duplicat link found") 
#				return
		links.append(new_link)
		
	update_linked()


func update_linked():
	
	for link in links:
		link.a.set_point_position(link.a_idx, link.b.get_point_position(link.b_idx))
	
	
func _draw():
	
	draw_circle(hover_pos, 4, Color.RED)
