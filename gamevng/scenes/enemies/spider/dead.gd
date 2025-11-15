extends EnemyState

## Spider Dead state - Tô màu đỏ đậm hơn

func _enter() -> void:
	obj.change_animation("dead")

	# Tô màu đỏ đậm cho sprite
	if obj.animated_sprite:
		obj.animated_sprite.modulate = Color(2.0, 0.3, 0.3, 1.0)  # Màu đỏ đậm hơn hurt

	timer = 0.5
	obj.velocity = Vector2(0, 0)
	obj.emit_signal("died")

func _update(delta: float) -> void:
	if update_timer(delta):
		obj.queue_free()
