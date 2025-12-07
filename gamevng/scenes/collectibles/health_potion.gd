extends BaseCollectible

@export var health_amount: int = 1
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()  # This sets collected=true, visible=false, monitoring=false
	print("Đã thu thập health potion!")
	
	# Use the sprite's texture from scene (should be coin texture now)
	var potion_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		potion_texture = sprite_2d.texture
		print("Using sprite texture: %s" % potion_texture)
	else:
		# Fallback to coin texture for visibility
		potion_texture = load("res://assets/items/coin/01.png")
		print("Fallback to coin texture")
	
	if not potion_texture:
		print("ERROR: Could not load potion texture!")
		return
	
	print("Health potion texture loaded: %s" % potion_texture)
	
	# Add to hotbar instead of using immediately
	var success = GUIManager.add_item_to_hotbar("health_potion", potion_texture, 1)
	if success:
		print("Health potion added to hotbar!")
		GUIManager.play_SFX("coin") # Reuse coin sound
