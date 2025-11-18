extends EnemyState

func _enter()->void:
	obj.velocity.x = obj.direction * -1 * 200
	obj.change_animation("hurt")
	timer = 0.5
func _update(delta: float)->void:
	if update_timer(delta):
		if (obj.health <=0):
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
