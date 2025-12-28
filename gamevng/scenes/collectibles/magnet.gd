extends BaseCollectible

## Magnet power-up item.

func _on_collect() -> void:
	if collected:
		return

	super._on_collect()
	GameManager.player.collect_powerup("magnet")
