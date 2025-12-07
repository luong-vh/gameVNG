extends BaseCollectible

## Damage Boost potion - increases player attack damage temporarily

@export var damage_boost_amount: int = 2
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()
	print("Đã thu thập damage boost potion!")
	
	# Use the sprite's texture from scene
	var potion_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		potion_texture = sprite_2d.texture
		print("Using damage potion texture: %s" % potion_texture)
	else:
		# Fallback
		potion_texture = load("res://assets/items/potions/pt1.png")
		print("Fallback to pt1 texture")
	
	if not potion_texture:
		print("ERROR: Could not load damage potion texture!")
		return
	
	print("Damage boost texture loaded: %s" % potion_texture)
	
	# Add to hotbar
	var success = GUIManager.add_item_to_hotbar("damage_boost", potion_texture, 1)
	if success:
		print("Damage boost potion added to hotbar!")
		GUIManager.play_SFX("coin")