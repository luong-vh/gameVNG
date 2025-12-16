extends EnemyState

var current_attack = 1
var has_fired = false

func _enter() -> void:
	current_attack = randi() % 2 + 1
	obj.change_animation("attack" + str(current_attack))
	obj.velocity.x = 0
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	has_fired = false

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(_delta: float) -> void:
	obj.velocity.x = 0
	
	if not has_fired:
		var fire_frame = 3 if current_attack == 1 else 6
		if obj.animated_sprite.frame >= fire_frame:
			if current_attack == 1:
				obj.fire_cannon()
			else:
				obj.fire_rocket()
			has_fired = true
	
	if not obj.animated_sprite.is_playing():
		change_state(fsm.states.idle)
