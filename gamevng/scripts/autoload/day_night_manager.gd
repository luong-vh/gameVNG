extends Node

enum State { DAY, NIGHT }
var current_state : State = State.DAY

var day_bg: ParallaxBackground
var night_bg: ParallaxBackground
var canvas_modulate: CanvasModulate

var night_color = Color("#3f2d4f")
var day_color   = Color("#ffffff")


signal state_changed(new_state : State)

func _ready():
	_apply_state(current_state)

func switch_state():
	if current_state == State.DAY:
		current_state = State.NIGHT
	else:
		current_state = State.DAY
	_apply_state(current_state)
	emit_signal("state_changed", current_state)

func _apply_state(state : State) -> void:
	if not day_bg or not night_bg or not canvas_modulate:
		return
	
	match state:
		State.DAY:
			day_bg.visible = true
			night_bg.visible = false
			canvas_modulate.color = day_color
		State.NIGHT:
			day_bg.visible = false
			night_bg.visible = true
			canvas_modulate.color = night_color
