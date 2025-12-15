extends PlayerState

func _enter():
	timer = 0.3
	obj.change_animation("attack")
	obj.hit_area_collision.disabled = false
	AudioManager.play_sound("sword_attack")
func _exit() -> void:
	obj.hit_area_collision.disabled = true

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)
		obj.start_attack_cd()
