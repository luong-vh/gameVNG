extends Node
class_name Stage

@export var default_day_night_state: DayNightManager.DayNightState

func _enter_tree() -> void:
	# Handle portal spawning first
	GameManager.current_stage = self
	
func _ready() -> void:
	_init_day_night()
	if not GameManager.respawn_at_portal():
		GameManager.respawn_at_checkpoint()
		
func reload()-> void:
	get_tree().reload_current_scene()

func _init_day_night():
	if has_node("DayParallaxBackground"):
		DayNightManager.day_bg = get_node("DayParallaxBackground")
	else:
		push_warning("DayParallaxBackground node not found")

	if has_node("NightParallaxBackground"):
		DayNightManager.night_bg = get_node("NightParallaxBackground")
	else:
		push_warning("NightParallaxBackground node not found")
	
	if has_node("DayNightCanvasModulate"):
		DayNightManager.canvas_modulate = get_node("DayNightCanvasModulate")
	else:
		push_warning("DayNightCanvasModulate node not found")
	
	DayNightManager.set_state(default_day_night_state)
