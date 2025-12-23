extends PlayerState

func _enter():
	obj.change_animation("throw")
	timer = 0.3

func _update(delta: float):
	if update_timer(delta):
		obj.throw_blade()
		change_state(fsm.previous_state)
