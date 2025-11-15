extends EnemyState

## Spider Hurt state - Tô màu đỏ cho sprite

func _enter() -> void:
	obj.velocity.x = obj.direction * -1 * 200
	obj.change_animation("hurt")

	# Tô màu đỏ cho sprite
	if obj.animated_sprite:
		obj.animated_sprite.modulate = Color(1.5, 0.5, 0.5, 1.0)  # Màu đỏ

	timer = 0.5

func _update(delta: float) -> void:
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)

func _exit() -> void:
	# Reset màu về bình thường
	if obj.animated_sprite:
		obj.animated_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Màu trắng (normal)
