extends PlayerState

func _enter():
	timer = 0.25
	obj.change_animation("pogo")
	obj.pogo_hit_area_collision.disabled = false

func _exit() -> void:
	obj.pogo_hit_area_collision.disabled = true

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)
