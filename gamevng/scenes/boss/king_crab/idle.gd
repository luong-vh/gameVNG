extends EnemyState

func _enter() -> void:
	obj.velocity.x = 0
	obj.change_animation("idle")
	
func _update(_delta: float) -> void:
	obj.velocity.x = 0
	
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x:
			obj.turn_right()
		else:
			obj.turn_left()
		change_state(fsm.states.moving)
	
	super._update(_delta)
