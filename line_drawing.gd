extends Node2D



class Point extends Resource:
	var line:Line2D
	var idx:int
	var distance:float #distance to cursor
	var position:Vector2
	
	func _to_string():
		if line:
			return str(line.name.replace("@",""),":", idx)
		else:
			return "?"
	# no _init here as it would break duplicate()?

var variables = []
class Variable:
	var value:Vector2
	var points:Array
	func _to_string():
#		return str(value, "@", points, "\n")
		return str(points,"\n")

var grabbed:Point
var hovered:Point
var best:Point

var active_line:Line2D
var pen_down


var move_key
var link_key
var edit_key
func _input(event):
	
	
	if event is InputEventMouseMotion:
		pen_down = event.pressure>0.001
	
#	move_key = event.is_command_or_control_pressed()
#	link_key = Input.is_key_pressed(KEY_SHIFT)
#	edit_key = Input.is_key_pressed(KEY_ALT)
	move_key = Input.is_key_pressed(KEY_SHIFT)
	link_key = Input.is_key_pressed(KEY_ALT)
#	edit_key = 
	
	#hovering a point
	if (move_key or link_key or edit_key):
		hovered = find_best_point( get_global_mouse_position() )
		queue_redraw()
	if event is InputEventMouseMotion:
		queue_redraw()
#		if (move_key or link_key or edit_key):
#			hovered = find_best_point(event.position)
	queue_redraw()
	
	#grab
	if event is InputEventMouseButton and move_key:
		if event.pressed:
			grabbed = find_best_point(event.position)
	
	
	#drop and link
	if event is InputEventMouseButton and not event.pressed:
			if grabbed and hovered and !link_key:
				link_variable()
			grabbed = null
	
	
	#drag point araound
	if event is InputEventMouseMotion and pen_down and move_key:
		if grabbed and grabbed.line:
			
#			if link_key:
#				remove_variable_from_point(grabbed)
			
			if move_key:
				for i in range(grabbed.line.points.size()): #for index,strength in grabbed ...
					#fall of towards the oposite end of the moved line
					
					grabbed.line.points[i] += event.relative*(i*0.05)
			
			grabbed.line.set_point_position(grabbed.idx, event.position)
			set_variable(grabbed, event.position)
			sync_variables()
	
	
	#draw new lines
	if event is InputEventMouseMotion:
		
		if not move_key and not link_key:
			
			#draw new line
			if !active_line and pen_down:
				active_line = Line2D.new()
				active_line.default_color = $"../HBoxContainer/fg".color
				active_line.width = 2
				add_child(active_line)
			#terminate if the pen is lifted
			if active_line and not pen_down:
				active_line = null
			#extend line by continue draggin mouse/pen
			if active_line and pen_down:
	#			var last = active_line.get_point_count()-1
	#			if active_line.get_point_position(last).distance_to(event.position) < 5:
	#				active_line.set_point_position(active_line.get_point_count()-1, event.position)
	#			else:
					active_line.add_point(event.position)


func link_variable():
	if grabbed.line and hovered.line:
		#merge instead
		if grabbed.line == hovered.line \
		and (grabbed.idx == grabbed.idx+1 or grabbed.idx == grabbed.idx-1):
			grabbed.line.remove_point(grabbed.idx)
			return
			
		var new_var = Variable.new()
		new_var.value = hovered.position
		new_var.points.append(hovered)
		new_var.points.append(grabbed) #.duplicate()) ???
#		print(" ADD ", new_var)
		variables.append(new_var)
func set_variable(target_point:Point, new_value:Vector2):
	for variable in variables:
		for point in variable.points:
#			print_debug(set_variable, point)
			if point.line == target_point.line and point.idx == target_point.idx:
				variable.value = new_value
#				print_debug("NEW ", new_value)
func sync_variables():
	for variable in variables:
		for point in variable.points:
			if point.line:
				point.line.set_point_position(point.idx, variable.value)
	$"../PanelContainer/Label".text = str(variables)
func remove_variable_from_point(target_point:Point):
	for j in range(variables.size()-1, 0, -1):
		var variable = variables[j]
		for i in range(variable.points.size()-1, 0, -1): #this looks a bit wonky, no?
			var point = variable.points[i]
			if point.line == target_point.line and point.idx == target_point.idx:
#				variable.points.remove_at(i)
#				if variable.points.size() == 1:
				variables.clear()
				return
#		print(variables)

func find_best_point(position:Vector2, best_distance:float=8):
	
	var best = Point.new()
	for line in get_children():
		
		var idx = 0
		for point in line.points:
			var distance = position.distance_to(line.position + point)
			if distance < best_distance:
				if grabbed and grabbed.line == line \
				and idx == grabbed.idx:
					continue #skipping self linking
				best.distance = distance
				best.position = line.position + point
				best.idx = idx
				best.line = line
			idx += 1
		
	return best



var default_font = SystemFont.new()
func _draw():
	
	if (move_key or link_key or edit_key) and hovered and hovered.line:# and not grabbed:
		var color = Color.WHITE
#		if variables: #if variables.has(hovered)...
#			for point in variables.points:
#				if point == hovered:
#					color = Color.DARK_SEA_GREEN
		draw_circle(hovered.position, 3, color)
		
		draw_string(default_font, hovered.position-Vector2(0,16), str(hovered.idx,"/",hovered.line.get_point_count()), HORIZONTAL_ALIGNMENT_CENTER, -1, 10 )
