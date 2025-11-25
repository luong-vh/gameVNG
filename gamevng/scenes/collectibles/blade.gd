extends BaseCollectible

## Blade power-up item. Grants the player the ability to use a blade.

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_collect() -> void:
	# Disable further collection
	monitoring = false
	
	# Call the player's collected_blade function
	GameManager.player.collect_powerup("blade")
	
	print("Player collected blade!")
	
	# If there's a collection animation, play it. Otherwise, just disappear.
	if animated_sprite and animated_sprite.sprite_frames.has_animation("collected"):
		animated_sprite.play("collected")
	else:
		queue_free()

func _on_animation_finished() -> void:
	# Disappear after the "collected" animation is done
	if animated_sprite.animation == "collected":
		queue_free()
