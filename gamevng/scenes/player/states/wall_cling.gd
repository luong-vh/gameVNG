extends PlayerState

func _enter() -> void:
	obj.change_animation("wall_cling")

func _update(_delta: float) -> void:
	#Control jump
	if control_jump():
		return
	
	control_wall_cling(_delta)
	
	control_moving()
	
	if not obj.is_near_wall():
		change_state(fsm.previous_state)
	
	if obj.is_on_floor():
		obj.jump_count = obj.max_jump_amount
		change_state(fsm.states.idle)
