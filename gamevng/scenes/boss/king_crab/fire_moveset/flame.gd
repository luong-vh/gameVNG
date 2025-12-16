extends Node2D

@export var lifetime: float = 2.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.play("default")
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()
