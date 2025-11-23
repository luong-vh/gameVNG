extends EnemyState

var phase = 1
func _enter()->void:
	obj.change_animation("attack")
	phase = 1
	timer = 0.6

func _update(delta: float)->void:
	if update_timer(delta):
		match phase:
			1:
				_attack()
				phase += 1
				timer = 0.3
			2:
				phase += 1
				timer = 0.3
			3:
				
				_attack()
				phase += 1
				timer = 0.3
			_:
				change_state(fsm.states.idle)
func _attack()->void:
	obj.fire()
	
