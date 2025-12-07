extends BaseCollectible

@export var health_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready() # Ensures the base class's _ready() is called
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	interact_input_action = "" # Auto-collect, no need to press key

func _on_collect():
	super._on_collect()  # This sets collected=true, visible=false, monitoring=false
	print("Đã thu thập health potion!")
	
	# Load texture dynamically to ensure it exists
	var potion_texture = load("res://assets/items/coin/01.png")
	if not potion_texture:
		print("ERROR: Could not load potion texture!")
		return
	
	print("Health potion texture loaded: %s" % potion_texture)
	
	# Add to hotbar instead of using immediately
	var success = GUIManager.add_item_to_hotbar("health_potion", potion_texture, 1)
	if success:
		print("Health potion added to hotbar!")
		GUIManager.play_SFX("coin") # Reuse coin sound
	
	# Play collected animation
	if animated_sprite_2d.visible:
		animated_sprite_2d.play("collected")

func _on_animation_finished():
	if animated_sprite_2d.animation == "collected":
		animated_sprite_2d.visible = false