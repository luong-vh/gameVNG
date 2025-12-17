extends SaveableObject
class_name Lever

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var can_be_deactivate: bool
@export var start_activated: bool = false  
var is_activated: bool = false

signal activated(is_activate: bool)

func _ready() -> void:
	is_activated = start_activated
	if is_activated:
		animated_sprite.play("activate")
	else:
		animated_sprite.play("deactivate")

func _on_hurt_area_2d_hurt(direction: Vector2, damage: float) -> void:
	_update_state(direction)
	pass

func _update_state(direction: Vector2):
	if direction.y > 0:
		return
	if direction == Vector2.ZERO:
		return

	if is_activated and can_be_deactivate and direction.x < 0:
		animated_sprite.play("deactivate")
		is_activated = false
		activated.emit(false)
	elif !is_activated and direction.x >= 0:
		animated_sprite.play("activate")
		is_activated = true
		activated.emit(true)

func get_state() -> Dictionary:
	return {
		"is_activated": is_activated,
		"can_be_deactivate": can_be_deactivate,
	}

func set_state(state: Dictionary) -> void:
	if state.has("is_activated"):
		is_activated = state.is_activated
		# Update visual without emitting signal
		if is_activated:
			animated_sprite.play("activate")
		else:
			animated_sprite.play("deactivate")

	if state.has("can_be_deactivate"):
		can_be_deactivate = state.can_be_deactivate
