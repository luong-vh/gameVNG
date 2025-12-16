extends Node2D

@export var activation_time: float = 0.2
@onready var activation_timer = $ActivationTimer
@export var cool_down_time: float = 1
@onready var cool_down_timer = $CoolDownTimer
@onready var animation_player = $AnimationPlayer

var activated: bool = false

func _ready() -> void:
	activation_timer.timeout.connect(_on_activation_timer_end)
	cool_down_timer.timeout.connect(_on_cool_down_timer_end)

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if activated:
		return
	activated = true
	
	activation_timer.start(activation_time)
	pass

func _on_activation_timer_end():
	animation_player.play("shake")
	cool_down_timer.start(cool_down_time)

func _on_cool_down_timer_end():
	animation_player.play("restart")
	activated = false
