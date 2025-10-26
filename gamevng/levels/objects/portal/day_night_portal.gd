extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _on_interactive_area_2d_interacted() -> void:
	DayNightManager.switch_state()
	$AnimatedSprite2D.play("close")

	await $AnimatedSprite2D.animation_finished
	queue_free()
