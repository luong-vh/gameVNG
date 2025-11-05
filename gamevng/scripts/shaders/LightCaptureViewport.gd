extends SubViewport
@export var target_scene: Stage  # assign "World" here
@export var follow_camera: Camera2D  # assign main Camera2D

# Editable light circle parameters
@export var circle_size: int = 512
@export var falloff: float = 4.0
@export var brightness: float = 1.0

var cam: Camera2D
var light_circles: Array = []

func _ready():
	size = get_viewport().size
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Black background
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.size = size
	add_child(bg)
	
	# Camera
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	
	if follow_camera:
		var remote := RemoteTransform2D.new()
		remote.remote_path = cam.get_path()
		follow_camera.add_child(remote)
	
	# Find ALL lights recursively
	if target_scene:
		var all_lights = get_all_lights(target_scene)
		print("Found ", all_lights.size(), " lights")
		for light in all_lights:
			var circle = create_light_circle(light)
			add_child(circle)
			light_circles.append({"sprite": circle, "light": light})

func get_all_lights(node: Node) -> Array[Light2D]:
	var lights: Array[Light2D] = []
	
	if node is Light2D and node.enabled and node.visible:
		lights.append(node)
	
	for child in node.get_children():
		lights.append_array(get_all_lights(child))
	
	return lights

func create_light_circle(light: PointLight2D) -> Sprite2D:
	var circle := Sprite2D.new()
	
	# Create a radial gradient texture
	var img := Image.create(circle_size, circle_size, false, Image.FORMAT_RGBA8)
	var center := Vector2(circle_size / 2, circle_size / 2)
	
	for x in range(circle_size):
		for y in range(circle_size):
			var dist = Vector2(x, y).distance_to(center)
			var max_dist = circle_size / 2.0
			
			# Smooth falloff from center to edge
			var intensity = clamp(1.0 - (dist / max_dist), 0.0, 1.0)
			intensity = pow(intensity, falloff)
			
			var alpha = intensity * light.energy * brightness
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	circle.texture = ImageTexture.create_from_image(img)
	circle.position = light.global_position
	
	# Scale based on light's texture_scale
	var radius = light.texture_scale
	circle.scale = Vector2.ONE * radius / (circle_size / 2.0)
	
	return circle

func _process(delta: float) -> void:
	# Update circle positions and properties
	for item in light_circles:
		item["sprite"].position = item["light"].global_position
		item["sprite"].scale = Vector2.ONE * item["light"].texture_scale * 200.0 / (circle_size / 2.0)
		item["sprite"].modulate.a = clamp(item["light"].energy * brightness, 0.0, 1.0)
		item["sprite"].visible = item["light"].enabled and item["light"].visible
