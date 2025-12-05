extends Area2D
class_name DayNightSwitchArea2D

@export var is_switching_day_night: bool
@export var day_night_state: DayNightManager.DayNightState
@export var is_switching_shader: bool
@export var shader_state: DayNightManager.ShaderState


func _on_area_entered(area: Area2D) -> void:
	if is_switching_day_night:
		DayNightManager.set_day_night_state(day_night_state)
	
	if is_switching_shader:
		DayNightManager.set_shader_state(shader_state)
