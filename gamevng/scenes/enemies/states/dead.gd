extends EnemyState
class_name EnemyDeadState


func _enter()->void:
	obj.change_animation("dead")
	timer = 1.0
	obj.velocity.x = 0
	if obj.has_method("drop_key"):
		obj.drop_key()
	obj.emit_signal("died")

func _update(delta: float)->void:
	if update_timer(delta):
		obj.queue_free()
