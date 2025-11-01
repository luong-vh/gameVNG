extends EnemyState

@export var attack_movement_speed = 200

var time_prepare:float = 0.3
var phase = 0

func _enter() -> void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	#timer = 1.2
	phase = 1
	timer = 0.3
	
	obj.velocity.x = 0

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(delta: float) -> void:
	#if time_prepare < 0:
		#obj.velocity.x = obj.direction * attack_movement_speed
	if update_timer(delta):
		if phase ==2:
			change_state(fsm.previous_state)
		else:
			obj.velocity.x = obj.direction * attack_movement_speed
			timer = 1
			phase = 2
