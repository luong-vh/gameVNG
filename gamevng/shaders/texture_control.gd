extends Control

@export var camera: Camera2D
@export var light_capture: LightCaptureViewport
var fog_texture: TextureRect

# Editable light circle parameters
@export var circle_size: int = 512
@export var falloff: float = 4.0
@export var brightness: float = 1.0

func _ready() -> void:
	#light_capture = $LightCaptureViewport
	if not light_capture:
		push_warning("Light Capture Viewport have not been assign")
	
	fog_texture = $TextureRect
	
	fog_texture.light_capture = light_capture
	
	light_capture.target_scene = GameManager.current_stage
	light_capture.circle_size = circle_size
	light_capture.falloff = falloff
	light_capture.brightness = brightness
	if camera:
		light_capture.follow_camera = camera
