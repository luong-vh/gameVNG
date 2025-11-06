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
		obj.velocity.x = obj.movement_speed * dir
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
	if obj.is_on_floor() or obj.is_near_wall():
		obj.jump_count = obj.max_jump_amount
	
	var jumpInput = Input.is_action_just_pressed("jump")
	if jumpInput:
		#Wall jump
		if obj.is_near_wall() and not obj.is_on_floor():
			obj.lock_input()
			var collision = obj.wall_checker.get_collision_normal()
			var wall_dir = int(collision.x)
			
			obj.velocity.x = wall_dir * obj.wall_jump_force
			obj.jump()
			obj.change_direction(wall_dir)
			change_state(fsm.states.jump)
			return true
		
		#Normal jump
		if obj.jump_count > 0:
			obj.jump_particle.restart()
			obj.jump_particle.emitting = true
			obj.jump()
			obj.jump_count -= 1
			change_state(fsm.states.jump)
			return true
	return false

func control_wall_cling(delta: float) -> bool:
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
	if obj.is_on_floor() or obj.is_near_wall():
		obj.dash_count = 0
	
	if obj.is_dash_on_cd() or obj.dash_count >= obj.dash_amount:
		return false
	
	var dash_input = Input.is_action_just_pressed("dash")
	if dash_input:
		fsm.change_state(fsm.states.dash)
		return true
	
	return false

func control_attack():
	if Input.is_action_just_pressed("switch_day_night"):
		DayNightManager.switch_state()
	
	if obj.invulnerable_timer.is_stopped():
		obj.is_invulnerable = false
	
	if Input.is_action_just_pressed("attack"):
		if obj.can_attack(): 
			fsm.change_state(fsm.states.attack)
	
	if Input.is_action_just_pressed("throw"):
		if obj.can_attack():
			obj.throw_blade()
			obj.change_animation("idle")

func take_damage(damage) -> void:
	#obj take damage
	if obj.is_invulnerable:
		return
	print("health %d" %obj.health)
	print("damage %d" %damage)
	obj.take_damage(damage)
	print("health %d" %obj.health)
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)
	return
