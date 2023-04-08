extends Spatial

var graph = {
	"A": ["B", "C"],
	"B": ["A", "C"],
	"C": ["A", "B", "D"],
	"D": ["C"],
}

var colors = {
	"A": Color.red,
	"B": Color.white,
	"C": Color.brown,
	"D": Color.green,
}

var created_edgies = []

func _ready():
	generate_graph()
	
func create_label(vertex, node):
	var label = Label.new()
	label.text = vertex
	label.rect_min_size = Vector2(30, 20)  # Adjust the size of the label if needed
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.set_name("label_" + vertex)
	get_node("ControlHolder").add_child(label)
	
	# Update the position of the label every frame
	set_process(true)

func _process(delta):
	update_label_positions()

func update_label_positions():
	var camera = get_viewport().get_camera()
	for vertex in graph:
		var node = get_node("GraphHolder/" + vertex)
		var label = get_node("ControlHolder/label_" + vertex)

		# Convert the 3D position of the node to 2D screen coordinates
		var screen_pos = camera.unproject_position(node.global_transform.origin)

		# Offset the label's position to display it below the node
		label.rect_position = screen_pos - label.rect_min_size / 2 + Vector2(0, 20)


func generate_graph():
	var graph_holder = get_node("GraphHolder")
	
	# First, create and store all the node instances
	var node_instances = {}
	var total_nodes = len(graph)
	var y_spacing = 5
	var i = 0

	for vertex in graph:
		# Create a node for the vertex and set its position
		var node = MeshInstance.new()
		node.set_mesh(SphereMesh.new())
		
		# Create a new material and set its color
		var material = SpatialMaterial.new()
		material.albedo_color = colors[vertex]

		# Assign the material to the node
		node.set_surface_material(0, material)
		
		if vertex == "A":
			node.set_translation(Vector3(0, 0, 0))
		else:
			node.set_translation(Vector3(rand_range(-10, 10), i * y_spacing, rand_range(-10, 10)))

		graph_holder.add_child(node)
		
		# Set a unique name for the node to reference it later
		node.set_name(vertex)
		node_instances[vertex] = node
		create_label(vertex, node)
		
		i += 1

	# Then, create the edges using the stored node instances (deferred)
	for vertex in graph:
		for neighbor in graph[vertex]:
			# Avoid creating duplicate edges
			if not graph_holder.has_node(neighbor + "_" + vertex):
				call_deferred("create_and_add_edge", node_instances[vertex], node_instances[neighbor], vertex, neighbor)

# ... rest of the code ...


func create_and_add_edge(start_node, end_node, start_name, end_name):
	if not created_edgies.has(start_name + "_" + end_name):
		print(created_edgies)
		print(start_name, end_name)
		var edge = create_edge(start_node, end_node)
		get_node("GraphHolder").add_child(edge)
		
		# Set a unique name for the edge
		created_edgies.append(end_name + "_" + start_name)
		edge.set_name(start_name + "_" + end_name)

func create_edge(start_node, end_node):
	print(start_node.global_transform.origin, end_node.global_transform.origin)
	var edge = Spatial.new()
	var cylinder = MeshInstance.new()
	cylinder.set_mesh(CylinderMesh.new())
	
	edge.add_child(cylinder)
	
	var start_pos = start_node.get_translation()
	var end_pos = end_node.get_translation()
	var diff = end_pos - start_pos
	var distance = diff.length()
	
	# Set cylinder position and scale
	cylinder.set_translation(Vector3(0, distance / 2, 0))
	cylinder.set_scale(Vector3(0.1, distance / 2, 0.1))
	
	# Calculate the direction vector and axis of rotation
	var direction = (end_pos - start_pos).normalized()
	print(direction)
	#var rotation_axis = direction.cross(Vector3.UP).normalized()
	#var rotation_angle = acos(direction.dot(Vector3.UP))
	
	var up = Vector3(0, 1, 0)
	var axis = up.cross(direction)
	var angle = acos(up.dot(direction))
	
	# Set the rotation and translation of the edge
	print(start_pos, axis, angle)
	edge.set_translation(start_pos)
	edge.rotate(axis.normalized(), angle)
	
	return edge
