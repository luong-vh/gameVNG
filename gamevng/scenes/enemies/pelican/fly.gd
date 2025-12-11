extends EnemyState

func _enter()->void:
	obj.change_animation("fly")
	timer = obj.attack_cool_down

func control_flying(delta: float) -> bool:
	obj.velocity.x = obj.movement_speed * obj.direction
	
	if obj.front_ray_cast.is_colliding():
		obj.turn_around()
	return true

func _update(delta: float)->void:
	control_flying(delta)

	if obj.direction > 0:
		if obj.global_position.x >= obj.patrol_end.x:
			obj.global_position.x = obj.patrol_end.x
			obj.turn_around()
	else:
		if obj.global_position.x <= obj.patrol_start.x:
			obj.global_position.x = obj.patrol_start.x
			obj.turn_around()
	
	if update_timer(delta):
		obj.velocity.x = 0
		change_state(fsm.states.attack)
	
	super._update(delta)
