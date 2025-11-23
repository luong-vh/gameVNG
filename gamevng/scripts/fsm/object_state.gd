class_name ObjectState
extends FSMState

## Base state class cho các object (StaticBody2D, AnimatableBody2D, etc.)
## FSMState giờ đã hỗ trợ obj: Node nên không cần override nữa

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(_delta: float) -> void:
	pass
