extends PlayerState

func _enter() -> void:
	#Change animation to run
	obj.change_animation("run")
	pass

func _update(_delta: float):
	#Control jump
	if control_jump():
		return
	#Control moving and if not moving change to idle
	if not control_moving():
		change_state(fsm.states.idle)
		return
	
	control_dash()
	
	control_attack()
	
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
		return
	var raycast = obj.raycast_pushable
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		obj.velocity.x = collider.try_to_push(obj.velocity.x, _delta)
		
