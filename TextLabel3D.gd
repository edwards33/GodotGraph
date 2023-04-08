extends Spatial

func _ready():
	var viewport_texture = ViewportTexture.new()
	viewport_texture.viewport_path = NodePath("TextViewport")
	
	var text_mesh = get_node("TextMesh")
	var material = text_mesh.get_surface_material(0)
	material.albedo_texture = viewport_texture

