extends Node2D

@export var impact_duration: float = 0.5
@export var damage_area_radius: float = 50.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_area = $HitArea2D

func _ready():
	if animated_sprite:
		animated_sprite.play("default")
	
	if hit_area:
		var collision_shape = hit_area.get_node_or_null("CollisionShape2D")
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = damage_area_radius
	
	await get_tree().create_timer(impact_duration).timeout
	queue_free()
