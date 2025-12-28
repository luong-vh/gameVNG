extends BaseCollectible

## Damage Boost potion - increases player attack damage temporarily

@export var damage_boost_amount: int = 2
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()

	var potion_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		potion_texture = sprite_2d.texture
	else:
		potion_texture = load("res://assets/items/potions/pt2.png")

	if not potion_texture:
		return

	GUIManager.add_item_to_hotbar("damage_boost", potion_texture, 1)
