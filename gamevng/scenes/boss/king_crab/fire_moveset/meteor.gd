extends Node2D

@export var fall_speed: float = 400.0
@export var ground_y: float = 0.0
@export var impact_offset: float = 0.0
@export var use_raycast: bool = true

var velocity: Vector2
var has_hit_ground: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var ground_raycast = $GroundRayCast2D
@onready var impact_scene = preload("res://scenes/boss/king_crab/fire_moveset/meteor_impact.tscn")

func _ready():
	velocity = Vector2(0, fall_speed)
	if animated_sprite:
		animated_sprite.play("default")

func _process(delta):
	if has_hit_ground:
		return
	
	position += velocity * delta
	
	# Check collision with ground using raycast
	if use_raycast and ground_raycast and ground_raycast.is_colliding():
		_hit_ground()
	# Fallback to Y position check
	elif position.y >= ground_y - impact_offset:
		_hit_ground()

func _hit_ground():
	has_hit_ground = true
	
	var parent_node = get_parent()
	var impact_position = position
	
	if impact_scene:
		var impact = impact_scene.instantiate()
		impact.position = impact_position
		parent_node.add_child(impact)
	
	queue_free()
