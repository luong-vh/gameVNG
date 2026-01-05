extends Node
class_name Stage

@export var can_switch_day_night: bool = true
@export var default_day_night_state: DayNightManager.DayNightState = DayNightManager.DayNightState.DAY
@export var default_shader_state: DayNightManager.ShaderState = DayNightManager.ShaderState.NONE
@export_range(0, 100, 1) var day_night_switch_limit: int = 2
@export var loading_time_sec: float = 5
@export var level_id: String = "5"
@export var has_intro_cutscene: bool = false  # Set to true for level 1
@export var intro_cutscene_path: String = "res://scenes/cutscenes/story_1/opening.tscn"

@export var total_coins := 25

func _enter_tree() -> void:
	GameManager.set_current_stage(self, level_id)
	if level_id == "0":
		assert(false,"Chưa khai báo level_id cho scene này!")

func _ready() -> void:
	# Check if this is the first time playing and has intro cutscene
	if has_intro_cutscene and _should_play_intro_cutscene():
		_play_intro_cutscene()
		return  # Don't initialize the level yet
	
	_init_level()

func _should_play_intro_cutscene() -> bool:
	# Check if this is the first time playing level 1
	return not GameManager.intro_cutscene_played

func _play_intro_cutscene() -> void:
	print("[Stage] Playing intro cutscene")
	# The cutscene will handle transitioning back to level 1
	get_tree().change_scene_to_file(intro_cutscene_path)

func _init_level() -> void:
	_init_day_night()
	if not GameManager.respawn_at_portal():
		GameManager.respawn_at_checkpoint()
	GUIManager.on_stage_scene()
	
	await get_tree().process_frame
	DayNightManager.resend_state()
	
	# If we just came from the cutscene, fade from black
	if GameManager.intro_cutscene_played and has_intro_cutscene:
		GUIManager.fade_from_black()

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
	DayNightManager.set_shader_state(default_shader_state)

func save_stage() -> Dictionary:
	var saved_node = get_tree().get_nodes_in_group("Saved Object")
	
	return {
		"stage_path": self.scene_file_path,
		"day_night_state": DayNightManager.current_day_night_state,
		"shader_state": DayNightManager.current_shader_state,
		"cur_switch_limit": DayNightManager.switch_limit_count,
		"total_coins": total_coins,
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
