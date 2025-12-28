extends BaseCollectible

@export var health_amount: int = 1
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()

	var potion_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		potion_texture = sprite_2d.texture
	else:
		potion_texture = load("res://assets/items/potions/pt1.png")

	GUIManager.add_item_to_hotbar("health_potion", potion_texture, 1)
