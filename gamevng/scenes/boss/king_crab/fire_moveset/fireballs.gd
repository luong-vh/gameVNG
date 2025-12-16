extends Node2D

@export var gravity: float = 980.0
@export var initial_velocity: Vector2 = Vector2(200, -400)
@export var ground_detection_offset: float = 80.0

var velocity: Vector2
var has_hit_ground: bool = false
var start_y: float

@onready var fire_spread_scene = preload("res://scenes/enemies/king_crab/fire_moveset/fire_spread.tscn")
@onready var flame_scene = preload("res://scenes/enemies/king_crab/fire_moveset/flame.tscn")
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	velocity = initial_velocity
	start_y = position.y
	if animated_sprite:
		animated_sprite.play("new_animation")

func set_velocity(new_velocity: Vector2) -> void:
	velocity = new_velocity
	initial_velocity = new_velocity

func _process(delta):
	if has_hit_ground:
		return
	
	velocity.y += gravity * delta
	position += velocity * delta
	
	if position.y >= start_y + ground_detection_offset:
		_hit_ground()

func _hit_ground():
	has_hit_ground = true
	
	var parent_node = get_parent()
	var impact_position = position
	
	var fire_spread = fire_spread_scene.instantiate()
	fire_spread.position = impact_position
	parent_node.add_child(fire_spread)
	
	queue_free()
