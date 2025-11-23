extends ObjectState


const EXTENDED_TIME = 0.3  

func _enter() -> void:
	var pistol = obj as Pistol
	pistol.show_extended()
	timer = EXTENDED_TIME

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)
