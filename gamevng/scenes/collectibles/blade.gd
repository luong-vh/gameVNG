extends BaseCollectible

## Blade power-up item. Grants the player the ability to use a blade.

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	print("[Blade] Blade collectible ready!")

func _on_collect() -> void:
	if collected:
		return  # Already collected

	super._on_collect()  # This now sets collected=true, visible=false, monitoring=false

	# Add blade to player (this will also add to hotbar automatically)
	if GameManager.player:
		GameManager.player.collect_blade()
		print("[Blade] Blade collected and added to player!")

	AudioManager.play_sound("coin")
