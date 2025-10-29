extends EnemyState

var phase = 1
func _enter()->void:
	obj.change_animation("attack")
	phase = 1
	timer =0.6
func _update(delta: float)->void:
	if update_timer(delta):
		if phase ==1:
			_attack()
			phase += 1
			timer =0.3
		else: 
			change_state(fsm.states.fly)
func _attack()->void:
	obj.fire()
	
