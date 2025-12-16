extends EnemyState

func _enter():
	obj.change_animation("hurt")
	timer = 0.2

func _update( delta: float):
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		elif obj.health <= obj.max_health * 0.5 and not obj.is_phase_2:
			obj.is_phase_2 = true
			if fsm.states.has("phasetransition"):
				change_state(fsm.states.phasetransition)
			else:
				change_state(fsm.default_state)
		else:
			change_state(fsm.default_state)
