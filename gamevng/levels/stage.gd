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
	
	if has_node("ShaderCanvasLayer"):
		DayNightManager.shader_canva = get_node("ShaderCanvasLayer")
	DayNightManager.set_state(default_day_night_state)

func save_stage() -> Dictionary:
	var saved_node = get_tree().get_nodes_in_group("Saved Object")
	
	return {
		"stage_path": self.scene_file_path,
		"day_night_state": DayNightManager.current_state,
		"shader_state": DayNightManager.current_shader_state,
	}

func load_state(data: Dictionary) -> bool:
	"""Load stage state from checkpoint data"""
	var stage_path = data.get("stage_path", "")
	if not stage_path or stage_path != self.scene_file_path:
		return false
	
	if data.has("day_night_state"):
		var state = data["day_night_state"]
		DayNightManager.set_state(state)
	
	if data.has("shader_state"):
		var state = data["shader_state"]
		DayNightManager.set_shader_state(state)
	
	return true
