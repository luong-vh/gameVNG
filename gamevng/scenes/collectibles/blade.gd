extends BaseCollectible

## Blade power-up item. Grants the player the ability to use a blade.

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_collect() -> void:
	super._on_collect()  # This now sets collected=true, visible=false, monitoring=false

	# Call the player's collected_blade function
	GameManager.player.collect_powerup("blade")

	print("Player collected blade!")

	# If there's a collection animation and sprite is visible, play it
	if animated_sprite and animated_sprite.sprite_frames.has_animation("collected") and animated_sprite.visible:
		animated_sprite.play("collected")

func _on_animation_finished() -> void:
	# Just hide after animation, don't queue_free() to preserve for save/load
	if animated_sprite.animation == "collected":
		animated_sprite.visible = false
