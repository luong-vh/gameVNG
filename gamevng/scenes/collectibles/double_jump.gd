extends BaseCollectible

## Double Jump power-up item.

func _on_collect() -> void:
	if collected:
		return

	super._on_collect()
	GameManager.player.collect_powerup("double_jump")
