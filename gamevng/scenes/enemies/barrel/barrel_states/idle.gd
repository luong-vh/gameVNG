extends EnemyState


func _enter()->void:
	obj.change_animation("idle")
	timer = 1.5
func _update(delta: float)->void:
	if update_timer(delta):
		if obj.behavior == "DAY":
			change_state(fsm.states.day_attack)
		else:
			change_state(fsm.states.night_attack)
