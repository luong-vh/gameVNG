extends Node
class_name Stage

@export var can_switch_day_night: bool = true
@export var default_day_night_state: DayNightManager.DayNightState
@export_range(0, 100, 1) var day_night_switch_limit: int = 2
@export var loading_time_sec: float = 5

func _enter_tree() -> void:
	# Handle portal spawning first
	GameManager.current_stage = self

func _ready() -> void:
	_init_day_night()
	if not GameManager.respawn_at_portal():
		GameManager.respawn_at_checkpoint()

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
	
	DayNightManager.set_can_switch_day_night(can_switch_day_night)
	DayNightManager.set_switch_limit(day_night_switch_limit)
	DayNightManager.set_day_night_state(default_day_night_state)

func save_stage() -> Dictionary:
	var saved_node = get_tree().get_nodes_in_group("Saved Object")
	
	return {
		"stage_path": self.scene_file_path,
		"day_night_state": DayNightManager.current_day_night_state,
		"shader_state": DayNightManager.current_shader_state,
		"cur_switch_limit": DayNightManager.switch_limit_count,
	}

func load_state(data: Dictionary) -> bool:
	"""Load stage state from checkpoint data"""
	var stage_path = data.get("stage_path", "")
	if not stage_path or stage_path != self.scene_file_path:
		return false
	
	if data.has("day_night_state"):
		var state = data["day_night_state"]
		DayNightManager.set_day_night_state(state)
	
	if data.has("shader_state"):
		var state = data["shader_state"]
		DayNightManager.set_shader_state(state)
	
	if data.has("cur_switch_limit"):
		var limit = data["cur_switch_limit"]
		DayNightManager.set_switch_limit(day_night_switch_limit)
		DayNightManager.set_limit_count(limit)
	
	return true
