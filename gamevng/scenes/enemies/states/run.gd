extends EnemyState


func _enter():
	obj.change_animation("normal")
	
func _update(delta: float)->void:
	if ((obj.is_can_fall() and obj.is_on_floor()) or obj.is_touch_wall()):
		obj.velocity.x = 0
		obj.turn_around()
	else:
		obj.velocity.x = obj.direction * obj.SPEED 
