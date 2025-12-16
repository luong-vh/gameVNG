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

	# Call player's collect_blade() function
	# This will add blade to hotbar slot 0 (not equipped yet)
	print("[Blade] Calling player.collect_blade()...")
	if GameManager.player:
		GameManager.player.collect_blade()
		print("[Blade] ✅ Blade collected! (Press 1 to equip)")
	else:
		print("[Blade] ❌ Player not found!")

	print("[Blade] Blade collection complete!")
