extends Node2D

signal spread_finished

@onready var animated_sprite = $AnimatedSprite2D
@onready var flame_scene = preload("res://scenes/boss/king_crab/fire_moveset/flame.tscn")

func _ready():
	if animated_sprite:
		animated_sprite.sprite_frames.set_animation_loop("default", false)
		animated_sprite.animation_finished.connect(_on_animation_finished)
		animated_sprite.play("default")

func _on_animation_finished():
	var flame = flame_scene.instantiate()
	flame.position = position
	get_parent().add_child(flame)
	
	queue_free()
