extends Spatial

var selected_node = null

var node_textures = {}

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
	"B": "https://freepngimg.com/thumb/kids/36098-9-little-baby-boy-transparent-background.png",
	"C": "https://freepngimg.com/thumb/baby/32385-4-baby-image.png",
	"D": "https://freepngimg.com/thumb/baby/32688-4-baby-transparent.png",
}

var nodes_to_request = []

var old_image_url = ''

func _on_http_request_completed(result, response_code, headers, body):
	var node_name = get_node("HTTPRequest").get_meta("node_name")
	var noimage = preload("res://noimage.png")
	if response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)

		if error == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			
			node_textures[node_name] = texture
			apply_texture_to_node(node_name, texture)
		else:
			print("1. Error loading image: ", error)
	else:
		apply_texture_to_node(node_name, noimage)
		print("1. Error downloading image, response code: ", response_code, " node name: ", node_name)

	process_next_request()

func _on_http_request_image_completed(result, response_code, headers, body):
	start_spinner(false)
	var noimage = preload("res://noimage.png")
	$NameEditPanel/NodeImageView.texture = noimage
	if response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		print('1---')
		if error == OK:
			print('2---')
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			var node_name = get_node("HTTPRequestImg").get_meta("node_name")
			
			# Set the texture of the NodeImageView
			print(node_name)
			print(selected_node.get_name())
			if node_name == selected_node.get_name():
				print('3---')
				print(texture)
				$NameEditPanel/NodeImageView.texture = texture
		else:
			print("2. Error loading image: ", error)
	else:
		print("2. Error downloading image, response code: ", response_code)

func _on_http_request_image_on_node_completed(result, response_code, headers, body):
	var node_name = get_node("HTTPRequestImgNode").get_meta("node_name")
	var noimage = preload("res://noimage.png")
	if response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		print('3.1---')
		if error == OK:
			print('3.2---')
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			
			node_textures[node_name] = texture
			print('3.3---')
			apply_texture_to_node(node_name, texture)
		else:
			apply_texture_to_node(node_name, noimage)
			print("3. Error loading image: ", error)
	else:
		apply_texture_to_node(node_name, noimage)
		print("3. Error downloading image, response code: ", response_code, " node name: ", node_name)

func _on_http_request_new_image_completed(result, response_code, headers, body):
	start_spinner(false)
	var noimage = preload("res://noimage.png")
	$NameEditPanel/NodeImageView.texture = noimage
	if response_code == 200:
		var image = Image.new()
		var error = image.load_png_from_buffer(body)
		print('4.1---')
		if error == OK:
			print('4.2---')
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			var node_name = get_node("HTTPRequestImg").get_meta("node_name")
			
			# Set the texture of the NodeImageView
			print(node_name)
			print(selected_node.get_name())
			if node_name == selected_node.get_name():
				print('4.3---')
				print(texture)
				$NameEditPanel/NodeImageView.texture = texture
		else:
			print("2. Error loading image: ", error)
	else:
		print("2. Error downloading image, response code: ", response_code)


func apply_texture_to_node(node_name, texture):
	var node = get_node("GraphHolder/" + node_name)
	print("node name: ", node_name)
	print("..1",node)
	
	# First, check if the node already has a child with a texture. If it does, remove it.
	if node.has_node("quad" + node_name):
		print('Remove old Image from Node')
		var old_quad = node.get_node("quad" + node_name)
		node.remove_child(old_quad)
		old_quad.queue_free()
		print("..2",node,old_quad)

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

	# Store a copy of the texture in the node for later use in UI
	node.set_meta("image_texture", texture.duplicate())  # duplicate the texture to ensure it's a separate instance

	# Finally, give the newly added quad a name so we can find it later
	quad.set_name("quad" + node_name)

func apply_new_texture_to_node(node_name, texture):
	var node = get_node("GraphHolder/" + node_name)
	print("#..1",node)
	
	var quad_mesh = QuadMesh.new()
	var material = SpatialMaterial.new()
	material.albedo_texture = texture
	material.flags_transparent = true
	material.flags_unshaded = true
	material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	quad_mesh.surface_set_material(0, material)
	
	node.set_mesh(quad_mesh)

	# Store a copy of the texture in the node for later use in UI
	node.set_meta("image_texture", texture.duplicate())  # duplicate the texture to ensure it's a separate instance
	quad_mesh.set_name("quad" + node_name)



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

	var http_request_image = HTTPRequest.new()
	add_child(http_request_image)
	http_request_image.set_name("HTTPRequestImg")
	http_request_image.connect("request_completed", self, "_on_http_request_image_completed")

	var http_request_image_on_node = HTTPRequest.new()
	add_child(http_request_image_on_node)
	http_request_image_on_node.set_name("HTTPRequestImgNode")
	http_request_image_on_node.connect("request_completed", self, "_on_http_request_image_on_node_completed")

	var http_request_new_image = HTTPRequest.new()
	add_child(http_request_new_image)
	http_request_new_image.set_name("HTTPRequestNewImg")
	http_request_new_image.connect("request_completed", self, "_on_http_request_new_image_completed")
	
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
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.border_color = Color(1, 1, 1, 1)
	style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	$NameEditPanel.set("custom_styles/panel", style)

	# Assuming your NameEdit is a direct child of the parent node. 
	# Adjust the path if it's not.
	var name_edit = $NameEditPanel/NameEdit

	# Increase the width (x value) of the rect_min_size.
	# This controls the minimum size of the NameEdit, so increasing it will make it wider.
	name_edit.rect_min_size.x += 300  # Add 100 units to the width
	
	# Move the NameEdit to the right.
	# This adjusts the position of the NameEdit, so adding to it will move it right.
	name_edit.rect_position.x += 50  # Move 20 units to the right
	name_edit.rect_position.y += 30  # Move 20 units to the right

	var panel = $NameEditPanel
	var node_image_view = $NameEditPanel/NodeImageView

	node_image_view.anchor_right = 1.0  # Anchors to the right edge of the panel
	node_image_view.anchor_bottom = 1.0  # Anchors to the bottom edge of the panel

	node_image_view.margin_left = 5.0
	node_image_view.margin_top = 65.0
	node_image_view.margin_right = -5.0  # Aligns with the right edge of the panel
	node_image_view.margin_bottom = -545.0  # Aligns with the bottom edge of the panel

	print("NodeImageView min size: ", node_image_view.rect_min_size)
	print("NodeImageView position: ", node_image_view.rect_position)
	print("NodeImageView margins: ", node_image_view.margin_left, " ", node_image_view.margin_top, " ", node_image_view.margin_right, " ", node_image_view.margin_bottom)

	# Assuming the Tween node is named "Tween"
	$NameEditPanel/Tween.connect("tween_completed", self, "_on_Tween_tween_completed")
	var tween = $NameEditPanel/Tween
	 # The property to animate, the initial value, the final value, the duration, the type of transition, the type of easing
	tween.interpolate_property($NameEditPanel/TextureProgress, "radial_initial_angle", $NameEditPanel/TextureProgress.radial_initial_angle, $NameEditPanel/TextureProgress.radial_initial_angle + 360, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	start_spinner(false)
	
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	$NameEditPanel/Tween.interpolate_property($NameEditPanel/TextureProgress, "radial_initial_angle", $NameEditPanel/TextureProgress.radial_initial_angle, $NameEditPanel/TextureProgress.radial_initial_angle + 360, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$NameEditPanel/Tween.start()

func start_spinner(start_sp):
	$NameEditPanel/TextureProgress.visible = start_sp
		
	if start_sp:
		$NameEditPanel/Tween.start()
	else:
		$NameEditPanel/Tween.stop_all()
	
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
				selected_node = colliding_node.get_parent()
				show_name_edit_panel()


func scale_to_fit(viewport_size, image_size):
	var scale_x = viewport_size.x / image_size.x
	var scale_y = viewport_size.y / image_size.y
	return Vector2(scale_x, scale_y)
				
func show_name_edit_panel():
	yield(get_tree(), "idle_frame")
	var panel = get_node("/root/Graph/NameEditPanel")
	var line_edit = get_node("/root/Graph/NameEditPanel/NameEdit")
	var image_view = get_node("/root/Graph/NameEditPanel/NodeImageView")

	old_image_url = images[selected_node.get_name()]
	
	panel.visible = true
	line_edit.text = selected_node.get_name()
	print("Selected Node Name: ", selected_node.get_name())

	var texture = preload("res://loading.png")

	start_spinner(true)
	
	$NameEditPanel/NodeImageView.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$NameEditPanel/NodeImageView.expand = true  # Set expand to true
	$NameEditPanel/NodeImageView.texture = texture

	#$NameEditPanel/NodeImageView.texture = null

	get_node("HTTPRequestImg").set_meta("node_name", selected_node.get_name())
	get_node("HTTPRequestImg").request(images[selected_node.get_name()])
	
	
	# If the selected node has a child MeshInstance node that contains the image, get the image and display it in the ImageView
	#if selected_node and selected_node.has_meta("image_texture"):
	#	var texture = selected_node.get_meta("image_texture")
	#	image_view.texture = texture

	print("SELECTED NODE: ", selected_node.get_name())
					
	line_edit.grab_focus()


func _on_SaveButton_pressed():
	print("2, SELECTED NODE: ", selected_node.get_name())
	if selected_node:
		var line_edit = get_node("/root/Graph/NameEditPanel/NameEdit")
		var new_text = line_edit.text

		# Remove the old label
		var old_label_name = "label_" + selected_node.get_name()
		var old_label = get_node("ControlHolder/" + old_label_name)

		# Update the text of the old label
		old_label.text = new_text		

		var image_edit = get_node("/root/Graph/NameEditPanel/ImageEdit")
		var new_image = image_edit.text

		if len(new_image) > 0:
			image_edit.text = ''
			get_node("HTTPRequestImgNode").set_meta("node_name", selected_node.get_name())
			get_node("HTTPRequestImgNode").request(new_image)
			
		selected_node = null
		
	old_image_url = ''
	get_node("NameEditPanel").visible = false

func _on_CancelButton_pressed():
	if selected_node:
		selected_node = null

	old_image_url = ''
	var image_edit = get_node("/root/Graph/NameEditPanel/ImageEdit")
	image_edit.text = ''

	get_node("NameEditPanel").visible = false

func _on_ReloadButton_pressed():
	var texture = preload("res://loading.png")

	#start_spinner(true)
	
	$NameEditPanel/NodeImageView.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$NameEditPanel/NodeImageView.expand = true  # Set expand to true
	$NameEditPanel/NodeImageView.texture = texture

	var image_edit = get_node("/root/Graph/NameEditPanel/ImageEdit")
	var new_image = image_edit.text

	get_node("HTTPRequestNewImg").set_meta("node_name", selected_node.get_name())
	get_node("HTTPRequestNewImg").request(new_image)

func _on_UseOldImageButton_pressed():
	var texture = preload("res://loading.png")

	#start_spinner(true)

	var image_edit = get_node("/root/Graph/NameEditPanel/ImageEdit")
	image_edit.text = ''
	
	$NameEditPanel/NodeImageView.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$NameEditPanel/NodeImageView.expand = true  # Set expand to true
	$NameEditPanel/NodeImageView.texture = texture

	get_node("HTTPRequestNewImg").set_meta("node_name", selected_node.get_name())
	get_node("HTTPRequestNewImg").request(old_image_url)
