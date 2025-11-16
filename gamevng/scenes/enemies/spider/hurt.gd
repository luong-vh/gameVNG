extends EnemyState

## Spider Hurt state - Tô màu đỏ cho sprite

func _enter() -> void:
	print("[Spider/Hurt] ENTERING HURT STATE - Health: ", obj.health, " / ", obj.max_health)

	obj.velocity.x = obj.direction * -1 * 200
	obj.change_animation("hurt")

	# Tô màu đỏ cho sprite
	if obj.animated_sprite:
		obj.animated_sprite.modulate = Color(1.5, 0.5, 0.5, 1.0)  # Màu đỏ

	timer = 0.5

func _update(delta: float) -> void:
	if update_timer(delta):
		if obj.health <= 0:
			print("[Spider/Hurt] Health depleted! Going to DEAD state")
			change_state(fsm.states.dead)
		else:
			# Quay lại state dựa vào behavior mode
			if obj.behavior_mode == Spider.BehaviorMode.HANGING:
				print("[Spider/Hurt] Recovered! Going back to HANG state")
				change_state(fsm.states.hang)
			else:
				print("[Spider/Hurt] Recovered! Going back to RUN state")
				change_state(fsm.states.run)

func _exit() -> void:
	# Reset màu về bình thường
	if obj.animated_sprite:
		obj.animated_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Màu trắng (normal)
