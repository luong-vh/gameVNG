extends RigidBody2D
class_name CoinDrop

@export var coin_amount: int = 1
@export var _have_gravity: bool = false
@onready var animated_sprite := $AnimatedSprite2D
@onready var interactive_area = $InteractiveArea2D

func _ready() -> void:
	interactive_area.interaction_available.connect(_on_interaction_available)
	set_gravity(_have_gravity)

func collect_coin():
	GameManager.inventory_system.add_coin(coin_amount)
	interactive_area.monitoring = false
	animated_sprite.play("collected")
	await animated_sprite.animation_finished
	queue_free()

func _on_interaction_available():
	collect_coin()

func set_gravity(value: bool):
	if _have_gravity != value:
		_have_gravity = value
	
	if _have_gravity:
		gravity_scale = 1
		sleeping = false
	else:
		gravity_scale = 0
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		sleeping = true
