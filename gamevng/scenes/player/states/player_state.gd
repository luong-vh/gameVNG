class_name PlayerState
extends FSMState

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	if obj.is_input_lock():
		return false

	var dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var is_moving: bool = abs(dir) > 0.1
	if is_moving:
		dir = sign(dir)
		obj.change_direction(dir)
		obj.velocity.x = obj.get_movement_speed() * dir
		if obj.is_on_floor():
			change_state(fsm.states.run)
		return true
	else:
		if obj.is_on_floor():
			obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if obj.is_input_lock():
		return false

	if obj.is_on_floor() or obj.is_near_wall():
		obj.reset_jump_count()
		obj.coyote_time_activated = false
		obj.coyote_timer.stop()
	else:
		if not obj.coyote_time_activated:
			obj.coyote_time_activated = true
			obj.coyote_timer.start()

	if Input.is_action_just_pressed("jump"):
		if obj.can_wall_cling and obj.is_near_wall() and not obj.is_on_floor():
			obj.lock_input(obj.wall_jump_lock_input_time)
			var collision = obj.wall_checker.get_collision_normal()
			var wall_dir = int(collision.x)

			obj.velocity.x = wall_dir * obj.wall_jump_force
			obj.jump()
			obj.change_direction(wall_dir)
			change_state(fsm.states.jump)
			return true

		if obj.jump_count < obj.max_jump_amount:
			if not (obj.is_on_floor() or not obj.coyote_timer.is_stopped()) and obj.is_near_wall():
				return false

			if obj.jump_count >= obj.normal_jump_cost and not obj.can_double_jump:
				return false

			if not obj.can_double_jump and not (obj.is_on_floor() or not obj.coyote_timer.is_stopped()):
				return false

			obj.jump_particle.restart()
			obj.jump_particle.emitting = true
			obj.jump()
			if obj.is_on_floor() or obj.is_near_wall():
				obj.jump_count += obj.normal_jump_cost
			else:
				obj.jump_count += obj.double_jump_cost
			change_state(fsm.states.jump)
			return true
	return false

func control_variable_jump_height():
	var is_wall_cling = obj.is_near_wall() and not obj.is_on_floor()
	if (Input.is_action_just_released("jump") and obj.velocity.y < 0
		and not is_wall_cling):
		obj.velocity.y *= obj.jump_cut_multiplier

func control_wall_cling(delta: float) -> bool:
	if not obj.can_wall_cling:
		return false

	var collision = obj.wall_checker.get_collision_normal()
	var wall_dir = int(collision.x)

	obj.change_direction(-wall_dir)
	if obj.velocity.y > 0:
		if obj.velocity.y > obj.wall_slide_speed:
			obj.velocity.y = obj.wall_slide_speed

		obj.velocity.y -= obj.wall_friction * delta
	else:
		return false
	change_state(fsm.states.wallcling)
	return true

func control_dash() -> bool:
	if obj.is_input_lock():
		return false

	if not obj.can_dash:
		return false
	
	if obj.is_on_floor() or obj.is_near_wall():
		obj.dash_count = 0
	
	if Input.is_action_just_pressed("dash"):
		if obj.is_dash_on_cd() or obj.dash_count >= obj.dash_amount:
			return false
		obj.velocity = Vector2.ZERO
		fsm.change_state(fsm.states.dash)
		return true
	return false

func control_attack() -> bool:
	if obj.is_input_lock():
		return false

	if (Input.is_action_pressed("down")
		and Input.is_action_just_pressed("attack")
		and not obj.is_on_floor()
	):
		if obj.can_attack():
			obj.change_attack_direction(obj.AttackDir.DOWN)
			obj.reset_jump_count()
			obj.reset_dash()
			fsm.change_state(fsm.states.pogo)
			return true
	
	if Input.is_action_just_pressed("attack"):
		if obj.can_attack():
			obj.change_attack_direction(obj.AttackDir.FORWARD)
			fsm.change_state(fsm.states.attack)
			return true
	
	if Input.is_action_just_pressed("throw"):
		if obj.can_attack():
			fsm.change_state(fsm.states.throw)
			return true
	
	return false

func take_damage(damage) -> void:
	if !obj.can_take_damage():
		return

	obj.health -= damage
	obj.set_invulnerable()

	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)
