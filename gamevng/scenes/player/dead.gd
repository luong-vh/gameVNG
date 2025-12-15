extends PlayerState

func _enter() -> void:
	timer = 0.5
	obj.change_animation("dead")
	pass

func _update(_delta: float) -> void:
	if update_timer(_delta):
		obj.velocity = Vector2(0,0)
		print("[Dead] Player died - respawning...")
		GameManager.respawn_at_checkpoint()
