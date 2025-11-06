extends PlayerState

func _enter() -> void:
	#Change animation to jump
	obj.change_animation("jump")
	pass

func _update(_delta: float):
	#Control moving
	control_moving()
	
	control_jump()
	
	control_dash()
	
	#If velocity.y is greater than 0 change to fall
	if obj.is_near_wall() and not obj.is_on_floor():
		change_state(fsm.states.wallcling)
	
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
	pass
