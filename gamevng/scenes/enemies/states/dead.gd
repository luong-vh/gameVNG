extends EnemyState


# Called when the node enters the scene tree for the first time.
func _enter()->void:
	obj.change_animation("dead")
	timer =0.5
	obj.velocity = Vector2(0,0)
	obj.emit_signal("died")

func _update(delta: float)->void:
	if update_timer(delta):
		obj.queue_free()
