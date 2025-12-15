extends BaseCollectible

## Magnet power-up item.

func _on_collect() -> void:
	if collected:
		return  # Already collected, prevent double collection

	# Call base class to set collected = true, visible = false, monitoring = false
	super._on_collect()

	# Call the player's collect_powerup function
	GameManager.player.collect_powerup("magnet")

	print("Player collected magnet!")
