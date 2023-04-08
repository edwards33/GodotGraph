extends Camera

export var rotation_speed = 0.5
export var zoom_speed = 5.0

var dragging = false
var previous_mouse_position = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				previous_mouse_position = event.position
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom_in(zoom_speed)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_out(zoom_speed)

	if dragging and event is InputEventMouseMotion:
		var delta = event.position - previous_mouse_position
		previous_mouse_position = event.position
		rotate_around_center(delta * rotation_speed)

func rotate_around_center(delta: Vector2):
	var rotation_y = Transform().rotated(Vector3.UP, delta.x * deg2rad(-1))
	var rotation_x = Transform().rotated(global_transform.basis.x, delta.y * deg2rad(1))
	global_transform = global_transform * rotation_y * rotation_x

func zoom_in(amount: float):
	var zoom = max(0.1, global_transform.origin.length() - amount)
	global_transform.origin = global_transform.origin.normalized() * zoom

func zoom_out(amount: float):
	var zoom = global_transform.origin.length() + amount
	global_transform.origin = global_transform.origin.normalized() * zoom
