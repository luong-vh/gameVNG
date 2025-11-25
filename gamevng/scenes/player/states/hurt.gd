extends PlayerState

func _enter() -> void:
	obj.change_animation("hurt")
	obj.velocity.x = 0
	obj.jump()
	timer = 0.5

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)
	
