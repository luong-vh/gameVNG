extends EnemyState

@export var attack_movement_speed = 200
@export var attack_time:float = 1
@export var time_prepare:float = 0.3
var phase = 0
var current_attack = 1

func _enter() -> void:
	if obj.health <= obj.max_health * 0.5:
		current_attack = randi() % 4 + 1
	else:
		current_attack = randi() % 2 + 1
	obj.change_animation("attack" + str(min(current_attack, 2)))
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	phase = 1
	timer = time_prepare
	obj.velocity.x = 0

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(delta: float) -> void:
	if update_timer(delta):
		if phase == 2:
			change_state(fsm.previous_state)
		else:
			if current_attack == 2:
				obj.fire()
			elif current_attack == 3:
				obj.fire_fireball()
			elif current_attack == 4:
				obj.cast_meteors()
			else:
				obj.velocity.x = obj.direction * attack_movement_speed
			timer = attack_time
			phase = 2
