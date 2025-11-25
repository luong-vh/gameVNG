extends AnimatableBody2D

@export var move_speed: float = 100.0
@export var move_distance: float = 200.0
@export var acceleration: float = 100

@export_enum("Vertical", "Horizontal") var movement_type: String = "Vertical"

var velocity: float = 0

var start_position: Vector2
# Direction of movement
# 1: Up/Right
# -1: Down/Left
var direction: int = 1


func _ready():
	start_position = global_position


func _physics_process(delta):
	# Update velocity
	velocity += acceleration * delta * direction
	velocity = clamp(velocity, -move_speed, move_speed)

	# Move platform based on movement type
	if movement_type == "Vertical":
		# Move up and down
		global_position.y += velocity * delta

		# Check if reached the limit
		if global_position.y >= start_position.y + move_distance:
			direction = -1
		elif global_position.y <= start_position.y - move_distance:
			direction = 1

	elif movement_type == "Horizontal":
		# Move left and right
		global_position.x += velocity * delta

		# Check if reached the limit
		if global_position.x >= start_position.x + move_distance:
			direction = -1
		elif global_position.x <= start_position.x - move_distance:
			direction = 1
