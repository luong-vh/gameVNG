extends AnimatableBody2D

@export var move_speed: float = 100.0
@export var move_distance: float = 200.0
@export var acceleration: float = 100

var velocity: float = 0

var start_position: Vector2
# Direction of movement
# 1: Up
# -1: Down
var direction: int = 1


func _ready():
	start_position = global_position


func _physics_process(delta):
	# Logic moving up and down
	var target_y = start_position.y + (move_distance * direction)
	velocity += acceleration * delta * direction
	velocity = clamp(velocity, -move_speed, move_speed)
	
	# Move platform with speed and direction
	global_position.y += velocity * delta
	
	# Check if reached the limit
	if global_position.y >= start_position.y + move_distance:
		direction = -1
	elif global_position.y <= start_position.y - move_distance:
		direction = 1
