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

func generate_graph():
	var graph_holder = get_node("GraphHolder")
	
	# First, create and store all the node instances
	var node_instances = {}
	for vertex in graph:
		# Create a node for the vertex and set its position
		var node = MeshInstance.new()
		node.set_mesh(SphereMesh.new())
		
		# Create a new material and set its color
		var material = SpatialMaterial.new()
		material.albedo_color = colors[vertex]

		# Assign the material to the node
		node.set_surface_material(0, material)
		
		node.set_translation(Vector3(rand_range(-10, 10), rand_range(-10, 10), rand_range(-10, 10)))
		graph_holder.add_child(node)
		
		# Set a unique name for the node to reference it later
		node.set_name(vertex)
		node_instances[vertex] = node

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
