extends EnemyState

func _enter() -> void:
	obj.velocity.x = 0
	obj.change_animation("idle")
	timer = obj.current_idle_time
	
func _update(delta: float) -> void:
	obj.velocity.x = 0
	
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x:
			obj.turn_right()
		else:
			obj.turn_left()
	
	if update_timer(delta):
		change_state(fsm.states.attack)
	
	super._update(delta)
