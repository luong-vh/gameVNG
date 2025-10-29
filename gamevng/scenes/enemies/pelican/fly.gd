extends EnemyState


func _enter()->void:
	obj.change_animation("fly")
	timer = 3
func _update(delta: float)->void:
	obj.velocity.x = obj.direction * obj.SPEED
	if obj.is_touch_wall():
		obj.turn_around()
	if update_timer(delta):
		change_state(fsm.states.attack)
