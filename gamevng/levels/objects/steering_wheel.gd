extends BaseCollectible

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()
	interact_input_action = ""

func _on_collect():
	super._on_collect()
	print("Đã thu thập bánh lái!")

	var wheel_texture: Texture2D = null
	if sprite_2d and sprite_2d.texture:
		wheel_texture = sprite_2d.texture
	else:
		wheel_texture = load("res://assets/island/objects/ship_helm/ship_helm_idle_01.png")

	if not wheel_texture:
		print("ERROR: Could not load steering wheel texture!")
		return

	var success = GUIManager.add_item_to_hotbar("steering_wheel", wheel_texture, 1)
	if success:
		print("Steering wheel added to hotbar!")
		GUIManager.play_SFX("coin")
