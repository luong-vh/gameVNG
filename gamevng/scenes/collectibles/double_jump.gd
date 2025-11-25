extends BaseCollectible

## Double Jump power-up item.

func _on_collect() -> void:
	# Disable further collection
	monitoring = false
	
	# Call the player's collect_powerup function
	GameManager.player.collect_powerup("double_jump")
	
	print("Player collected double jump!")
	
	# Immediately disappear
	queue_free()
