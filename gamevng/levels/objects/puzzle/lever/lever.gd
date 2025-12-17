extends SaveableObject
class_name Clever

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_hurt_area = $LeftHurtArea2D
@onready var right_hurt_area = $RightHurtArea2D

@export var can_be_deactivate: bool
@export var start_activated: bool = false  ## Trạng thái ban đầu của lever
var activated: bool = false

signal lever_hitted(is_activate: bool)

func _ready() -> void:
	# Set trạng thái ban đầu mà không emit signal
	activated = start_activated
	if activated:
		animated_sprite.play("activate")
	else:
		animated_sprite.play("deactivate")

func _on_hurt_area_2d_hurt(direction: Vector2, damage: float) -> void:
	_update_state(direction)
	pass

func _update_state(direction: Vector2):
	# Ignore attacks from below
	if direction.y > 0:
		return

	# Ignore if no actual direction (happens during initialization)
	if direction == Vector2.ZERO:
		return

	# Deactivate: đánh từ bên trái (direction.x < 0)
	if activated and can_be_deactivate and direction.x < 0:
		animated_sprite.play("deactivate")
		activated = false
		lever_hitted.emit(false)
		print("[Lever] Deactivated")
	# Activate: đánh từ bên phải (direction.x > 0)
	elif !activated and direction.x > 0:
		animated_sprite.play("activate")
		activated = true
		lever_hitted.emit(true)
		print("[Lever] Activated")

func get_state() -> Dictionary:
	return {
		"activated": activated,
		"can_be_deactivate": can_be_deactivate,
	}

func set_state(state: Dictionary) -> void:
	if state.has("activated"):
		activated = state.activated
		# Update visual without emitting signal
		if activated:
			animated_sprite.play("activate")
		else:
			animated_sprite.play("deactivate")

	if state.has("can_be_deactivate"):
		can_be_deactivate = state.can_be_deactivate
