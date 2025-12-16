extends RigidBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_area = $HitArea2D

func _ready():
	hit_area.body_entered.connect(_on_body_entered)
	gravity_scale = 0.0

func set_bullet_type(type: String):
	if animated_sprite:
		animated_sprite.play(type)
	
	elif type == "rocket":
		gravity_scale = 1.0

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()

func _on_body_entered(_body: Node) -> void:
	queue_free()
