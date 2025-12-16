extends BaseCollectible

@export var key_amount: int = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_key_collectible: bool = true

func _ready() -> void:
	super._ready()
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_collect():
	if collected:
		return

	collected = true
	monitoring = false
	GameManager.inventory_system.add_key(key_amount)
	animated_sprite_2d.play("collected")

func _on_animation_finished():
	if animated_sprite_2d.animation == "collected":
		visible = false

func set_state(state: Dictionary) -> void:
	super.set_state(state)

	if state.has("collected") and state.collected == false:
		if animated_sprite_2d.sprite_frames.has_animation("idle"):
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.stop()
			animated_sprite_2d.frame = 0
