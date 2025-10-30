extends TextureRect

@export var light_capture: SubViewport

func _ready():
	# Wait for light capture to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Connect the light mask texture to fog shader
	if light_capture:
		var light_texture = light_capture.get_texture()
		material.set_shader_parameter("light_mask", light_texture)
		print("Fog: Light mask connected")
	else:
		push_warning("Fog: No LightCaptureViewport found!")

# Call this if you dynamically add/remove lights
func refresh_lights():
	if light_capture:
		light_capture.refresh_lights()
