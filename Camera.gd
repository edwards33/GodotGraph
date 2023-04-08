extends Camera

export(float) var zoom_speed = 5.0
export(float) var rotation_speed = 0.5

var last_mouse_position = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom_in(zoom_speed)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out(zoom_speed)
	
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			var graph_holder = get_parent().get_node("GraphHolder")
			var rotation_delta = event.relative * rotation_speed
			
			graph_holder.rotate_x(deg2rad(-rotation_delta.y))
			graph_holder.rotate_y(deg2rad(-rotation_delta.x))

func _process(delta):
	last_mouse_position = get_viewport().get_mouse_position()

func zoom_in(amount):
	var new_translation = global_transform.origin - global_transform.basis.z * amount
	global_translate(new_translation - global_transform.origin)

func zoom_out(amount):
	var new_translation = global_transform.origin + global_transform.basis.z * amount
	global_translate(new_translation - global_transform.origin)
