extends BaseCollectible

## Blade power-up item. Grants the player the ability to use a blade.

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	print("[Blade] Blade collectible ready!")

func _on_collect() -> void:
	if collected:
		return  # Already collected

	print("[Blade] _on_collect() called!")
	super._on_collect()  # This now sets collected=true, visible=false, monitoring=false
	if GameManager.player:
		GameManager.player.collect_blade()
