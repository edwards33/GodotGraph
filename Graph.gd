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

var images = {
	"A": "https://pngimg.com/uploads/baby/baby_PNG51756.png",
	"B": "https://th.bing.com/th/id/R.60215ab247dfdf4f132757ddc6a5b33b?rik=F8HXZPtgCUWuNA&pid=ImgRaw&r=0",
	"C": "https://pngimg.com/uploads/baby/baby_PNG51756.png",
	"D": "https://www.odense.dk/emneromboernogfamilier/-/media/websites/emneromboernogfamilier/billeder/baby-i-ble,-der-kravler.png",
}

var nodes_to_request = []

func _on_http_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)

		if error == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			var node_name = get_node("HTTPRequest").get_meta("node_name")
			apply_texture_to_node(node_name, texture)
		else:
			print("Error loading image: ", error)
	else:
		print("Error downloading image, response code: ", response_code)

	process_next_request()


func apply_texture_to_node(node_name, texture):
	var node = get_node("GraphHolder/" + node_name)
	
	var quad_mesh = QuadMesh.new()
	var material = SpatialMaterial.new()
	material.albedo_texture = texture
	material.flags_transparent = true
	material.flags_unshaded = true
	material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	quad_mesh.surface_set_material(0, material)
	
	var quad = MeshInstance.new()
	quad.set_mesh(quad_mesh)
	node.add_child(quad)

	# Position the quad slightly above the surface of the sphere
	var sphere_radius = 1.0 # Assuming the default sphere radius of 1.0
	quad.set_translation(Vector3(0, sphere_radius + 0.5, 0))



func process_next_request():
	if nodes_to_request.size() > 0:
		var vertex = nodes_to_request.pop_front()
		get_node("HTTPRequest").set_meta("node_name", vertex)
		get_node("HTTPRequest").request(images[vertex])


var created_edgies = []

func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.set_name("HTTPRequest")
	http_request.connect("request_completed", self, "_on_http_request_completed")
	
	generate_graph()
	
	# Add RayCast node
	var raycast = RayCast.new()
	add_child(raycast)
	raycast.set_name("RayCast")
	raycast.enabled = true
	#raycast.collision_layer = 1 << 0  # Set the RayCast collision layer
	#raycast.collision_mask = 1 << 0   # Set the RayCast collision mask

	# Enable input processing
	set_process_input(true)
	
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
		
		# Add a StaticBody with a CollisionShape as a child of the MeshInstance
		var static_body = StaticBody.new()
		var collision_shape = CollisionShape.new()
		collision_shape.set_shape(SphereShape.new())
		static_body.add_child(collision_shape)
		node.add_child(static_body)

		# Set the collision layer for the StaticBody node
		static_body.set_collision_layer(1 << 0)
		
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
		nodes_to_request.append(vertex)
	process_next_request()
	

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

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		# Get the camera and viewport
		var camera = get_viewport().get_camera()

		# Cast a ray from the camera to the mouse position
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000

		# Prepare the space state for raycasting
		var space_state = get_world().direct_space_state

		# Perform the raycast
		var result = space_state.intersect_ray(from, to)

		if result.size() > 0:
			var colliding_node = result["collider"]
			if colliding_node is StaticBody:
				print("Selected node:", colliding_node.get_parent().get_name())


