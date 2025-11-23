extends Node

var day_bg: ParallaxBackground
var night_bg: ParallaxBackground
var canvas_modulate: CanvasModulate
var night_color = Color("#3f2d4f")
var day_color   = Color("#ffffff")

enum DayNightState { DAY, NIGHT }
var _current_day_night_state : DayNightState
var current_day_night_state: DayNightState:
	get: return _current_day_night_state

var switch_limit: int = 0
var _can_switch_day_night: bool = true
var _switch_limit_count: int = 0
var switch_limit_count: int:
	get: return _switch_limit_count

var shader_canva: CanvasLayer
enum ShaderState { DARKNESS, FOG, NONE }
var _current_shader_state: ShaderState = ShaderState.NONE
var current_shader_state: ShaderState:
	get: return _current_shader_state


signal day_night_state_changed(new_state : DayNightState)
signal shader_stage_changed(new_state: ShaderState)

func _ready():
	call_deferred("_init_state")

func is_day() -> bool:
	if _current_day_night_state == DayNightState.DAY:
		return true
	return false

func set_can_switch_day_night(value: bool):
	_can_switch_day_night = value

func switch_day_night_state():
	if not _can_switch_day_night:
		return
	
	if _switch_limit_count <= 0:
		#print("[DayNightManager] Reach switch day night limt")
		return
	else:
		_switch_limit_count -= 1
	
	if _current_day_night_state == DayNightState.DAY:
		_current_day_night_state = DayNightState.NIGHT
	else:
		_current_day_night_state = DayNightState.DAY
	_apply_state(_current_day_night_state)

func _init_state():
	_apply_state(_current_day_night_state)

func set_day_night_state(state: DayNightState):
	if state != _current_day_night_state:
		_current_day_night_state = state
		_apply_state(_current_day_night_state)

func set_switch_limit(limit: int):
	if limit <= 0:
		switch_limit = 0
		return
	
	switch_limit = limit
	_switch_limit_count = switch_limit

func reset_limit():
	_switch_limit_count = switch_limit

func set_limit_count(value: int):
	if value <= 0:
		_switch_limit_count = 0
		return
	
	_switch_limit_count = value

func _apply_state(state : DayNightState) -> void:	
	#print("[DayNightManager] Applying state:", state)
	if not day_bg or not night_bg or not canvas_modulate:
		return
	
	match state:
		DayNightState.DAY:
			day_bg.visible = true
			night_bg.visible = false
			canvas_modulate.color = day_color
			if shader_canva:
				shader_canva.turn_off_darkness()
			#print("Switched to DAY mode")
		DayNightState.NIGHT:
			day_bg.visible = false
			night_bg.visible = true
			canvas_modulate.color = night_color
			if shader_canva:
				shader_canva.turn_on_darkness()
			
			print("Switched to NIGHT mode")
		_:
			print("[DayNightManager] Background or modulate node not set yet!")
	emit_signal("day_night_state_changed", _current_day_night_state)

func resend_state():
	emit_signal("day_night_state_changed", _current_day_night_state)

# ---------- SHADER STAGE CONTROL ----------
func set_shader_state(state: ShaderState):
	if state != _current_shader_state:
		_current_shader_state = state
		_apply_shader_state(state)
		emit_signal("shader_stage_changed", state)


func _apply_shader_state(state: ShaderState):
	if not shader_canva:
		push_warning("Shader canvas not set!")
		return

	match state:
		ShaderState.DARKNESS:
			shader_canva.call("turn_on_darkness")
			shader_canva.call("turn_off_fog")
			print("Shader switched to DARKNESS")

		ShaderState.FOG:
			shader_canva.call("turn_on_fog")
			shader_canva.call("turn_off_darkness")
			print("Shader switched to FOG")
		
		ShaderState.NONE:
			shader_canva.call("turn_off_darkness")
			shader_canva.call("turn_off_fog")
