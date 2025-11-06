extends Control
class_name ShaderControl

@export var light_capture: LightCaptureViewport
@onready var texture_rect: TextureRect = $TextureRect
@export var texture_visible: bool = true:
	set(value):
		if value == texture_visible:
			return
		texture_visible = value
		if texture_rect:
			if value:
				texture_rect.show_texture()
			else:
				texture_rect.hide_texture()

func _ready() -> void:
	if light_capture:
		texture_rect.light_capture = light_capture
		light_capture.target_scene = GameManager.current_stage
		if GameManager.main_camera:
			light_capture.follow_camera = GameManager.main_camera
	else:
		push_warning("Light Capture Viewport has not been assigned")
	
	if texture_visible:
		texture_rect.show_texture()
	else:
		texture_rect.hide_texture()
