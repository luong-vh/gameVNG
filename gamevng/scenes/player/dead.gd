extends PlayerState

func _enter() -> void:
	timer = 0.5
	obj.change_animation("dead")
	pass

func _update(_delta: float) -> void:
	if update_timer(_delta):
		obj.velocity = Vector2(0,0)
		if GameManager.has_checkpoint():
			print("respawn")
			GameManager.respawn_at_checkpoint()
		else:
			print("No checkpoint available")
			print("Reload current scene")
			GameManager.reload_current_scene()
