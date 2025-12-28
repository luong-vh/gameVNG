extends BaseCollectible

## SpeedUp power-up item. Can be collected and used later from hotbar.

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect() -> void:
	super._on_collect()

	var speed_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		speed_texture = sprite_2d.texture
	else:
		speed_texture = load("res://assets/items/speed_up.png")

	if not speed_texture:
		return

	GUIManager.add_item_to_hotbar("speed_boost", speed_texture, 1)
	GUIManager.play_SFX("coin")
