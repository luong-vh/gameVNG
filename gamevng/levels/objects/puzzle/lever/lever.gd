extends SaveableObject
class_name Clever

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_hurt_area = $LeftHurtArea2D
@onready var right_hurt_area = $RightHurtArea2D

@export var can_be_deactivate: bool
var activated: bool

signal lever_hitted(is_activate: bool)

func _ready() -> void:
	_update_state(Vector2.ZERO)
	pass

func _on_hurt_area_2d_hurt(direction: Vector2, damage: float) -> void:
	_update_state(direction)
	pass

func _update_state(direction: Vector2):
	if direction.y > 0:
		return
	
	if activated and can_be_deactivate and direction.x <= 0:
		animated_sprite.play("deactivate")
		activated = false
		lever_hitted.emit(false)
	elif !activated and direction.x >= 0:
		animated_sprite.play("activate")
		activated = true
		lever_hitted.emit(true)

func get_state() -> Dictionary:
	return {
		"activated": activated,
		"can_be_deactivate": can_be_deactivate,
	}

func set_state(state: Dictionary) -> void:
	if state.has("activated"):
		activated = state.activated
		_update_state(Vector2.ZERO)
	
	if state.has("can_be_deactivate"):
		can_be_deactivate = state.can_be_deactivate
