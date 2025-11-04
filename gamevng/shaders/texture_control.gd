extends Control

@export var camera: Camera2D
@export var light_capture: LightCaptureViewport
var fog_texture: TextureRect

func _ready() -> void:
	#light_capture = $LightCaptureViewport
	if not light_capture:
		push_warning("Light Capture Viewport have not been assign")
	
	fog_texture = $TextureRect
	
	fog_texture.light_capture = light_capture
	
	light_capture.target_scene = GameManager.current_stage
	if camera:
		light_capture.follow_camera = camera
