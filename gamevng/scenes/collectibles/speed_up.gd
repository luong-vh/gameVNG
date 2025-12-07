extends BaseCollectible

## SpeedUp power-up item. Can be collected and used later from hotbar.

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect() -> void:
	super._on_collect()  # This sets collected=true, visible=false, monitoring=false
	print("Đã thu thập speed boost!")
	
	# Load speed_up texture - use the sprite's texture
	var speed_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		speed_texture = sprite_2d.texture
	else:
		# Fallback to load from file
		speed_texture = load("res://assets/items/speed_up.png")
	
	if not speed_texture:
		print("ERROR: Could not load speed_up texture!")
		return
	
	print("Speed boost texture loaded: %s" % speed_texture)
	
	# Add to hotbar instead of using immediately
	var success = GUIManager.add_item_to_hotbar("speed_boost", speed_texture, 1)
	if success:
		print("Speed boost added to hotbar!")
		GUIManager.play_SFX("coin") # Reuse coin sound
