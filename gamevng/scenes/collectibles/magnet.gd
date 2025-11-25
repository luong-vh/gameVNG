extends BaseCollectible

## Magnet power-up item.

func _on_collect() -> void:
	# Disable further collection
	monitoring = false
	
	# Call the player's collect_powerup function
	GameManager.player.collect_powerup("magnet")
	
	print("Player collected magnet!")
	
	# Immediately disappear
	queue_free()
