extends TextureRect

var light_capture: LightCaptureViewport
var tween: Tween
var default_thickness: float = 0.5   # your normal fog density
var fade_thickness := 0.0    # the value when hidden (min fog)

func _ready() -> void:
	if material:
		default_thickness = material.get_shader_parameter("thickness")

func _process(delta: float) -> void:
	if light_capture:
		var light_texture = light_capture.get_texture()
		material.set_shader_parameter("light_mask", light_texture)
	else:
		push_warning("No LightCaptureViewport found!")

# Fade in (increase shader thickness)
func show_texture(duration: float = 1.0) -> void:
	if tween:
		tween.kill()
	material.set_shader_parameter("thickness", fade_thickness)
	tween = create_tween()
	tween.tween_method(
		func(value): material.set_shader_parameter("thickness", value),
		fade_thickness,
		default_thickness,
		duration
	)

# Fade out (reduce shader thickness)
func hide_texture(duration: float = 1.0) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(
		func(value): material.set_shader_parameter("thickness", value),
		material.get_shader_parameter("thickness"),
		fade_thickness,
		duration
	)
