extends EnemyState


# Called when the node enters the scene tree for the first time.
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
