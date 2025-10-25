extends PlayerState

@onready var hurt_timer = $Timer
# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	obj.change_animation("hurt")
	obj.velocity.x = 0
	obj.jump()
	hurt_timer.start()
	obj.invulnerable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _update(delta: float) -> void:
	if hurt_timer.is_stopped():
		change_state(fsm.states.idle)
	
