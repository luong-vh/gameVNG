extends Node2D

@onready var light_source = $PointLight2D

func _ready() -> void:
	DayNightManager.day_night_state_changed.connect(_day_night_changed)
	
	if DayNightManager.current_day_night_state == DayNightManager.DayNightState.DAY:
		light_source.enabled = false
		$AnimatedSprite2D.play("turn_off")
	else:
		light_source.enabled = true
		$AnimatedSprite2D.play("turn_on")

func _day_night_changed(new_state):
	if new_state == DayNightManager.DayNightState.DAY:
		light_source.enabled = false
		$AnimatedSprite2D.play("turn_off")
	else:
		light_source.enabled = true
		$AnimatedSprite2D.play("turn_on")
