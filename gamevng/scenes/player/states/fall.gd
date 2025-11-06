extends PlayerState

func _enter() -> void:
	#Change animation to fall
	obj.change_animation("fall")
	pass

func _update(_delta: float) -> void:
	#Control moving
	var is_moving: bool = control_moving()
	
	control_dash()
	
	control_attack()
	
	var is_jumping = control_jump()
	
	if obj.is_near_wall() and not obj.is_on_floor():
		change_state(fsm.states.wallcling)
	
	if obj.is_on_floor():
		if not is_moving and not is_jumping:
			change_state(fsm.states.idle)
	pass
