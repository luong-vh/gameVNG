extends PlayerState


func _enter() -> void:
	obj.jump_count = obj.max_jump_amount
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
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
		return
	var raycast = obj.raycast_right if obj.direction == 1 else obj.raycast_left
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		obj.velocity.x = collider.try_to_push(obj.velocity.x, _delta)
		
