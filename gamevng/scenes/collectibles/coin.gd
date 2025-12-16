extends BaseCollectible

@export var coin_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called, which connects interaction_available
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_collect():
	# Check if this is first time collection BEFORE calling super
	var was_visible = visible

	super._on_collect()  # This now sets collected=true, visible=false, monitoring=false
	print("Đã thu thập " + str(coin_amount) + " coin!")

	GameManager.inventory_system.add_coin(coin_amount)
	AudioManager.play_sound("coin")
	# Play collected animation if this was first time collection
	if was_visible:
		visible = true  # Temporarily show for animation
		animated_sprite_2d.play("collected")

func _on_animation_finished():
	# Just hide after animation, don't queue_free() to preserve for save/load
	if animated_sprite_2d.animation == "collected":
		animated_sprite_2d.visible = false
