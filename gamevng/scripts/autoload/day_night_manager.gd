extends Node

enum DayNightState { DAY, NIGHT }
var current_state : DayNightState = DayNightState.DAY

var day_bg: ParallaxBackground
var night_bg: ParallaxBackground
var canvas_modulate: CanvasModulate

var night_color = Color("#3f2d4f")
var day_color   = Color("#ffffff")


signal state_changed(new_state : DayNightState)

func _ready():
	call_deferred("_init_state")

func switch_state():
	if current_state == DayNightState.DAY:
		current_state = DayNightState.NIGHT
	else:
		current_state = DayNightState.DAY
	_apply_state(current_state)
	

func _init_state():
	_apply_state(current_state)

func _apply_state(state : DayNightState) -> void:
	if not day_bg or not night_bg or not canvas_modulate:
		return
	
	match state:
		DayNightState.DAY:
			day_bg.visible = true
			night_bg.visible = false
			canvas_modulate.color = day_color
		DayNightState.NIGHT:
			day_bg.visible = false
			night_bg.visible = true
			canvas_modulate.color = night_color
	
	emit_signal("state_changed", current_state)
