extends PlayerState

func _enter() -> void:
	obj.change_animation("dash")
	timer = obj.dash_time
	obj.dash_count += 1
	obj.velocity.x = obj.dash_speed * obj.direction
	obj.velocity.y = 0
	if obj.dash_particle:
		obj.dash_particle.emitting = true
		obj.dash_particle.process_material.direction.x = obj.direction

func _update(_delta: float) -> void:
	obj.velocity.y = 0

	if update_timer(_delta):
		obj.dash_particle.emitting = false
		obj.start_dash_cd()
		change_state(fsm.previous_state)

func _exit():
	obj.dash_particle.emitting = false
