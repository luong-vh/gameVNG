extends SubViewport
class_name LightCaptureViewport

var target_scene: Stage
var follow_camera: Camera2D
var cam: Camera2D
var light_circles: Array = []

func _ready():
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Camera setup
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	
	
	if follow_camera:
		cam.zoom = follow_camera.zoom
		var remote := RemoteTransform2D.new()
		remote.remote_path = cam.get_path()
		follow_camera.add_child(remote)
	else:
		push_warning("LightCaptureViewport: No follow_camera assigned! The SubViewport camera will not follow anything.")
	
	# Find ALL lights recursively in target_scene
	if target_scene:
		var all_lights = get_all_lights(target_scene)
		print("Found ", all_lights.size(), " lights")
		
		for light in all_lights:
			var circle = create_light_circle(light)
			add_child(circle)
			light_circles.append({"sprite": circle, "light": light})

# Recursive function to find all Light2D nodes
func get_all_lights(node: Node) -> Array[Light2D]:
	var lights: Array[Light2D] = []
	if node is Light2D and node.enabled and node.visible:
		lights.append(node)
	for child in node.get_children():
		lights.append_array(get_all_lights(child))
	return lights

# Create a sprite representing the light
func create_light_circle(light: PointLight2D) -> Sprite2D:
	var circle := Sprite2D.new()
	
	# Use the same texture as the PointLight2D or fallback
	circle.texture = light.texture if light.texture else preload("res://assets/day_night/light.png")
	
	# Match color (we'll override alpha later)
	circle.modulate = light.color
	
	# Additive blending for glow
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	circle.material = mat
	
	return circle

func _process(delta: float) -> void:
	for item in light_circles:
		var light = item["light"]
		var sprite = item["sprite"]
		
		# Update position
		sprite.global_position = light.global_position
		
		var base_scale: float = light.texture_scale
		var energy_scale: float = clamp(light.energy, 0.1, 8.0)
		var desired_scale: float = base_scale * energy_scale
		var texture_size: float = 0.0
		if sprite.texture:
			texture_size = max(sprite.texture.get_width(), sprite.texture.get_height())
		
		var light_radius: float = light.radius if light.has_method("radius") else 500.0
		if texture_size > 0:
			var actual_radius: float = (texture_size / 2.0) * desired_scale
			if actual_radius > light_radius:
				desired_scale = (light_radius * 2.0) / texture_size
		
		sprite.scale = Vector2.ONE * desired_scale
		
		# Calculate per-light intensity (clamped between 0.0 and 1.0)
		var intensity: float = clamp(light.energy * 0.7, 0.0, 5.0)
		sprite.modulate = Color(1, 1, 1, intensity)
		
		# Update visibility
		sprite.visible = light.enabled and light.visible
