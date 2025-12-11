extends EnemyState

var _throw_timer: float = 0.0
var _phase: int = 0
var _is_throwing: bool = false

var anim: AnimatedSprite2D
var _waiting_for_anim: bool = false

func _enter() -> void:
	if anim == null:
		anim = obj.get_node_or_null("Direction/AnimatedSprite2D")
		if anim == null:
			push_error("[Hide] AnimatedSprite2D not found at 'Direction/AnimatedSprite2D'. Check the path!")
			return

	obj.change_animation("walk")
	_throw_timer = 0.0
	_phase = 0
	_is_throwing = false
	_waiting_for_anim = false
	if not anim.is_connected("animation_finished", Callable(self, "_on_anim_finished")):
		anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _exit() -> void:
	if anim != null and anim.is_connected("animation_finished", Callable(self, "_on_anim_finished")):
		anim.disconnect("animation_finished", Callable(self, "_on_anim_finished"))

func _on_anim_finished():
	if anim.animation == "throw":
		_waiting_for_anim = false
		print("[Throw] Animation 'throw' finished, continue to next phase")


func _update(delta : float ) -> void:
	obj.velocity.x = obj.direction * obj.movement_speed * 0.3
	_throw_timer += delta


	if _throw_timer >= obj.throw_interval and not _is_throwing:  # Sử dụng biến từ obj
		_is_throwing = true
		_phase = 0
		_throw_timer = 0.0

	if _waiting_for_anim:
		return

	if _is_throwing:
		match _phase:
			0:
				# Phase 0: Throw coconut towards player
				obj.change_animation("throw")
				_throw_coconut()
				_waiting_for_anim = true
				_phase = 1

			1:
				# Phase 1: Return to Walk state after animation finishes
				_is_throwing = false
				_phase = 0
				print("change to Walk")
				change_state(fsm.states.walk)

func _throw_coconut() -> void:
	print("\n===== THROW COCONUT =====")
	obj.throw_coconut()
