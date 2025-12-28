extends BaseCollectible

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()

	var shield_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		shield_texture = sprite_2d.texture
	else:
		shield_texture = load("res://assets/items/shield.png")

	GUIManager.add_item_to_hotbar("shield", shield_texture, 1)
