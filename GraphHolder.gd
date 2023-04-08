extends Spatial

export var rotation_speed = 0.5

var dragging = false
var previous_mouse_position = Vector2()
var graph_holder

func _ready():
	set_process_input(true)
	graph_holder = get_node("GraphHolder")
	print("GraphHolder node:", graph_holder)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				previous_mouse_position = event.position

	if dragging and event is InputEventMouseMotion:
		var delta = event.position - previous_mouse_position
		previous_mouse_position = event.position
		rotate_graph(delta * rotation_speed)

func rotate_graph(delta: Vector2):
	var rotation_y = Transform().rotated(Vector3.UP, delta.x * deg2rad(-1))
	var rotation_x = Transform().rotated(graph_holder.global_transform.basis.x, delta.y * deg2rad(1))
	graph_holder.global_transform = graph_holder.global_transform * rotation_y * rotation_x
