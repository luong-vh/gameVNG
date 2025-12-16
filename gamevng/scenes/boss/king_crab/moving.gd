extends EnemyState

func _enter() -> void:
	if obj.health <= obj.max_health * 0.5:
		obj.change_animation("angry")
	else:
		obj.change_animation("default")
	
func _update(_delta: float) -> void:
	obj.velocity.x = obj.movement_speed * obj.direction
	
	var enemy = obj as EnemyCharacter
	if enemy == null:
		return
	
	if not enemy.down_ray_cast.is_colliding() and enemy.is_on_floor():
		enemy.turn_around()
	
	if enemy.front_ray_cast.is_colliding():
		enemy.turn_around()
	
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x:
			obj.turn_right()
		else:
			obj.turn_left()
		change_state(fsm.states.attack)
	
	super._update(_delta)
