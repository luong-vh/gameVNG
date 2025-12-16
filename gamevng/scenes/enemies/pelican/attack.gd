extends EnemyState

@export var attack_delay: float = 0.3
var attack_delay_timer: float = 0

func _enter() -> void:
	timer = 0.5
	attack_delay_timer = 0
	obj.change_animation("attack")

func _update(delta: float) -> void:
	super._update(delta)
	attack_delay_timer += delta
	if attack_delay_timer > attack_delay:
		obj.fire()
		attack_delay_timer = 0
	
	if update_timer(delta):
		change_state(fsm.previous_state)
