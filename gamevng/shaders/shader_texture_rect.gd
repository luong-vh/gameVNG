extends TextureRect

var light_capture: LightCaptureViewport

func _process(delta: float) -> void:
	if light_capture:
		var light_texture = light_capture.get_texture()
		material.set_shader_parameter("light_mask", light_texture)
	else:
		push_warning("No LightCaptureViewport found!")
