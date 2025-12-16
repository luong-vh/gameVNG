extends Node2D
class_name Torch

@export var use_day_night := true

@onready var light_source = $PointLight2D
@onready var sprite = $AnimatedSprite2D

var manual_override := false
var desired_on := true

func _ready() -> void:
	if use_day_night:
		DayNightManager.day_night_state_changed.connect(_update_light)
	
	await get_tree().process_frame
	_update_light()

func _update_light():
	if manual_override:
		_apply(desired_on)
		return
	
	var should_be_on := desired_on
	if use_day_night:
		should_be_on = should_be_on and !DayNightManager.is_day()
	
	_apply(should_be_on)

func _apply(on: bool):
	light_source.enabled = on
	if on:
		sprite.play("turn_on")
	else:
		sprite.play("turn_off")

func turn_on():
	manual_override = true
	desired_on = true
	_apply(true)

func turn_off():
	manual_override = true
	desired_on = false
	_apply(false)

func set_active(active: bool):
	# Controlled by LeverControl (no manual override)
	manual_override = false
	desired_on = active
	_update_light()

func clear_manual_override():
	manual_override = false
	_update_light()
