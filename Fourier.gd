extends Node2D

var arrowratio = 5.0
var arrowthicc = 65.0
var pointercolor = Color(1,1,1)
var circlecolor = Color8(3,198,252)

var state = "NO DRAWING"
var draw_own = true
var follow = false

var drawing_coords = []
var drawing_value = PoolVector2Array()
var fourier_drawing = []

var fourier_series = []

var time = 0
var speed = 10.0

#EXPORTS
export var step = 0.05
export var num_of_vectors = 51


class SeriesElement:
	var speed
	var start_angle
	var radius
	
	func _init(_speed, _start_angle, _radius):
		speed = _speed
		start_angle = _start_angle
		radius = _radius
	func get_speed():
		return speed
	func get_start_angle():
		return start_angle
	func get_radius():
		return radius
	func get_current_angle(t):
		return start_angle + 2*PI*speed*t

func draw_circle_and_pointer(center, radius, angle):
	if radius<=0:
		print("HUH")
		return
	#Dont ask why cuz i dunno/ i know now since godot coordinate system +for y is down
	angle = -angle 

	var nb_points = 50
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(i * 360 / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polyline(points_arc, circlecolor)
	points_arc = PoolVector2Array([center + Vector2(0,radius/arrowthicc).rotated(angle),
								center + Vector2(radius-radius/arrowratio,radius/arrowthicc).rotated(angle), 
								center + Vector2(radius-radius/arrowratio, radius/arrowratio/sqrt(3)).rotated(angle),
								center + Vector2(radius,0).rotated(angle),
								center + Vector2(radius-radius/arrowratio, -radius/arrowratio/sqrt(3)).rotated(angle),
								center + Vector2(radius-radius/arrowratio,-radius/arrowthicc).rotated(angle), 
								center + Vector2(0,-radius/arrowthicc).rotated(angle)])
	draw_polygon(points_arc, PoolColorArray([pointercolor]))


func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if state == "DRAWING":
			state = "GENERATING SERIES"
			update_state()
			drawing_value.append(drawing_value[0])
			#interpolate sorta
			var new_cords = PoolVector2Array()
			for i in range(0,len(drawing_value)-1):
				var a = drawing_value[i]
				var b = drawing_value[i+1]
				var steps = float(ceil((a-b).length()/step))
				for x in range(0,steps):
					new_cords.append(a+(b-a)*x/steps)
			new_cords.append(new_cords[0])
			drawing_value = new_cords
			drawing_coords = [[drawing_value[0]]]
			for i in range(1,len(drawing_value)):
				if len(drawing_coords[-1])==15000:
					drawing_coords.append([drawing_coords[-1][-1]])
				drawing_coords[-1].append(drawing_value[i])
			update()
			print(len(drawing_value))
			generate_series()
		if state == "START DRAWING":
			state = "DRAWING"
			update_state()
			drawing_coords = [[get_global_mouse_position()]]
		if state == "RENDERING SERIES":
			if event.button_index==BUTTON_WHEEL_UP:
				get_node("Camera").set_zoom(get_node("Camera").get_zoom()*1.05)
			if event.button_index==BUTTON_WHEEL_DOWN:
				get_node("Camera").set_zoom(get_node("Camera").get_zoom()*0.95)
	elif event is InputEventMouseMotion:
		if state == "DRAWING":
			drawing_value.append(get_global_mouse_position())
			#This is since u cant draw to many lines i think
			if len(drawing_coords[-1])==15000:
				drawing_coords.append([drawing_coords[-1][-1]])
			drawing_coords[-1].append(get_global_mouse_position())
			update()
	elif event is InputEventKey:
		pass


func _draw():
	if state == "RENDERING SERIES":
		var center = Vector2(0,0)
		for element in fourier_series:
			if element.get_radius()>0:
				var current_angle = element.get_current_angle(time)
				draw_circle_and_pointer(center, element.get_radius(), current_angle)
				#-sin is neccesary as godot coords +y is down but we want it up
				center = center + Vector2(cos(current_angle), -sin(current_angle))*element.get_radius()
		if follow:
			get_node("Camera").set_offset(center)
		if draw_own:
			for lines in drawing_coords:
				draw_polyline(lines, Color(1,0,0))
		for lines in fourier_drawing:
			draw_polyline(lines, Color8(252,223,3))
			


	if state == "DRAWING" or state == "GENERATING SERIES":
		for lines in drawing_coords:
			draw_polyline(lines, Color(1,0,0))


func _process(delta):
	if state == "RENDERING SERIES":
		time = min(1.0000001,time+speed/(len(drawing_value)-1))
		if time>1:
			time = 0
		update()

func update_state():
	get_node("CanvasLayer/Label").set_text("STATE: " + state)

func generate_series():
	fourier_series = []
	var timeframe = 1.0/(len(drawing_value)-1)
	var c0 = Vector2()
	for t in range(0,len(drawing_value)):
		c0 = c0 + drawing_value[t] * timeframe
	fourier_series.append(SeriesElement.new(0, -c0.angle(), c0.length()))
#	print(str(0) + " " + str(c0.angle()) + " " + str(c0.length()))
	for i in range(1,num_of_vectors):
		for n in [i, -i]:
			var c = Vector2()
			for t in range(0,len(drawing_value)):
				c = c + (2*Vector2(0,c0.y) + Vector2(drawing_value[t].x, - drawing_value[t].y)).rotated(-2*PI*n*t*timeframe) * timeframe
			fourier_series.append(SeriesElement.new(n, c.angle(), c.length()))
#			print("["+str(n) + ", " + str(c.angle()) + ", " + str(c.length())+"],")
	for t in range(0,len(drawing_value)):
		var center = Vector2(0,0)
		for element in fourier_series:
			if element.get_radius()>0:
				var current_angle = element.get_current_angle(t*timeframe)
				#-sin is neccesary as godot coords +y is down but we want it up				
				center = center + Vector2(cos(current_angle), -sin(current_angle))*element.get_radius()
		if t==0:
			fourier_drawing.append([center])
		else:
			if len(fourier_drawing[-1])==15000:
				fourier_drawing.append([fourier_drawing[-1][-1]])
			fourier_drawing[-1].append(center)
		
	state = "RENDERING SERIES"
	update_state()
	update()



func _on_NEW_PATH_pressed():
	state = "START DRAWING"
	update_state()
	drawing_coords = []
	drawing_value = PoolVector2Array()
	fourier_drawing = []
	update()
	


func _on_DRAWING_pressed():
	draw_own = !draw_own


func _on_Speed_Slider_value_changed(value):
	speed = value/5.0
	get_node("CanvasLayer/Speed Slider/Speed").set_text("Speed: " + str(int(value)))


func _on_FOLLOW_pressed():
	follow = true


func _on_ORIGIN_pressed():
	follow = false
	get_node("Camera").set_offset(Vector2(0,0))
	get_node("Camera").set_zoom(Vector2(1,1))
