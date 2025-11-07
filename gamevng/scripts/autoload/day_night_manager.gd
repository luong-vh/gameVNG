extends Node

enum DayNightState { DAY, NIGHT }
var current_state : DayNightState
var day_bg: ParallaxBackground
var night_bg: ParallaxBackground
var canvas_modulate: CanvasModulate

var shader_canva: CanvasLayer
enum ShaderState { DARKNESS, FOG, NONE }
var current_shader_state: ShaderState = ShaderState.NONE

var night_color = Color("#3f2d4f")
var day_color   = Color("#ffffff")


signal state_changed(new_state : DayNightState)
signal shader_stage_changed(new_state: ShaderState)

func _ready():
	call_deferred("_init_state")

func is_day() -> bool:
	if current_state == DayNightState.DAY:
		return true
	return false

func switch_state():
	if current_state == DayNightState.DAY:
		current_state = DayNightState.NIGHT
	else:
		current_state = DayNightState.DAY
	_apply_state(current_state)
	

func _init_state():
	_apply_state(current_state)

func set_state(state: DayNightState):
	if state != current_state:
		current_state = state
		_apply_state(current_state)

func _apply_state(state : DayNightState) -> void:
	print("[DayNightManager] Applying state:", state)
	if not day_bg or not night_bg or not canvas_modulate:
		return
	
	match state:
		DayNightState.DAY:
			day_bg.visible = true
			night_bg.visible = false
			canvas_modulate.color = day_color
			if shader_canva:
				shader_canva.turn_off_darkness()
			print("Switched to DAY mode")
		DayNightState.NIGHT:
			day_bg.visible = false
			night_bg.visible = true
			canvas_modulate.color = night_color
			if shader_canva:
				shader_canva.turn_on_darkness()
			
			print("Switched to NIGHT mode")
		_:
			print("[DayNightManager] Background or modulate node not set yet!")
	emit_signal("state_changed", current_state)

func resend_state():
	emit_signal("state_changed", current_state)

# ---------- SHADER STAGE CONTROL ----------
func set_shader_state(state: ShaderState):
	if state != current_shader_state:
		current_shader_state = state
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
