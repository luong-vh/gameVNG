extends BaseCollectible

@export var coin_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called, which connects interaction_available
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_collect():
	super._on_collect()
	monitoring = false
	print("Đã thu thập " + str(coin_amount) + " coin!")
	animated_sprite_2d.play("collected")
	
	GameManager.inventory_system.add_coin(coin_amount)

func _on_animation_finished():
	if animated_sprite_2d.animation == "collected":
		queue_free() # Tự hủy sau khi animation "collected" chạy xong
