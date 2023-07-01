extends TextureRect

# The desired dimensions of the NodeImageView
var desired_size = Vector2(100, 100)

# The texture assigned to the NodeImageView
var image_texture = null

func _ready():
	# Adjust the size of the NodeImageView
	self.rect_min_size = desired_size
	self.rect_pivot_offset = desired_size / 2.0
	self.rect_clip_content = true

func set_texture(texture):
	image_texture = texture
	adjust_texture()

func adjust_texture():
	if image_texture == null:
		return

	# Calculate the aspect ratio of the texture
	var aspect_ratio = image_texture.get_width() / image_texture.get_height()

	# Set the stretch mode
	self.stretch_mode = STRETCH_KEEP_ASPECT_CENTERED

	# Scale the texture based on its aspect ratio and the desired dimensions
	if image_texture.get_width() > image_texture.get_height():
		self.rect_min_size = Vector2(desired_size.x, desired_size.x / aspect_ratio)
	else:
		self.rect_min_size = Vector2(desired_size.y * aspect_ratio, desired_size.y)
