extends PlayerState

func _enter() -> void:
	obj.change_animation("dash")
	timer = obj.dash_length
	obj.dash_count += 1
	obj.velocity.x = obj.dash_speed * obj.direction
	obj.velocity.y = 0
	if obj.dash_particle:
		var material = obj.dash_particle.process_material as ParticleProcessMaterial
		if material:
			material.direction.x = obj.direction
		obj.dash_particle.emitting = true

func _update(_delta: float) -> void:
	obj.velocity.y = 0

	if update_timer(_delta):
		obj.dash_particle.emitting = false
		obj.start_dash_cd()
		obj.velocity.x = 0
		change_state(fsm.states.idle)

func _exit():
	obj.dash_particle.emitting = false
