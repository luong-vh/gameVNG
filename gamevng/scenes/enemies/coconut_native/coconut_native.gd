extends EnemyCharacter

var raycast_right: RayCast2D
var raycast_left: RayCast2D

@onready var coconut_factory = $Direction/CoconutFactory
@export var bullet_speed : float = 150

@export_group("Walk Parameters")
@export var pause_time: float = 1.0  # Thời gian dừng trước khi quay đầu
@export var move_distance: float = 450  # Khoảng cách di chuyển trước khi quay đầu

@export_group("Throw Parameters")
@export var throw_interval: float = 2.0  # Thời gian giữa các lần ném (seconds)
@export var throw_angle: float = 55.0  # Góc ném (degrees, góc cao = dễ né hơn)
@export var attack_speed: float = 100  # Tốc độ di chuyển khi attack
@export var patrol_distance: float = 150  # Khoảng cách patrol khi throw

@export_group("Accuracy Settings")
@export var aim_offset_x: float = 15.0  # Độ lệch ngang (pixels)
@export var aim_offset_y: float = 10.0  # Độ lệch dọc (pixels)
@export var min_throw_distance: float = 100.0  # Khoảng cách ném tối thiểu
@export var max_throw_distance: float = 500.0  # Khoảng cách ném tối đa

func _ready() -> void:
	fsm = FSM.new(self , $States ,$States/Walk)
	type = "NATIVE"
	spawn_only_at_night = false
	spawn_point = global_position
	if has_node("CheckLeft"):
		raycast_left = $CheckLeft
	if has_node("CheckRight"):
		raycast_right = $CheckRight
	super._ready()

func _process(delta: float) -> void:
	detect_player()

func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	print("[%s] → DAY:  (spawn handled by manager)" % name)


func change_to_night_behavior():
	print("[%s] → NIGHT: Hide Native")
	_delete_from_enemy_manager()
	queue_free()
	pass

func _is_attack() -> bool:
	if found_player != null:
		return true
	return false

func throw_coconut() -> void:
	var coconut := coconut_factory.create() as RigidBody2D

	# Get target position (player position with random offset)
	var target_pos: Vector2
	if found_player != null:
		# Aim at player with random offset for unpredictability
		var offset = Vector2(
			randf_range(-aim_offset_x, aim_offset_x),
			randf_range(-aim_offset_y, aim_offset_y)
		)
		target_pos = found_player.global_position + offset
	else:
		# Fallback: throw forward if no player found
		target_pos = coconut_factory.global_position + Vector2(direction * 300, 0)

	# Calculate distance to target
	var start_pos = coconut_factory.global_position
	var delta_pos = target_pos - start_pos
	var dx = abs(delta_pos.x)
	var dy = delta_pos.y  # Positive if target is below, negative if above

	# Clamp distance to valid range
	dx = clamp(dx, min_throw_distance, max_throw_distance)

	# Determine throw direction (towards player)
	var throw_dir = sign(delta_pos.x)
	if throw_dir == 0:
		throw_dir = direction  # Fallback to enemy facing direction

	# Update enemy direction to face the target before throwing
	if throw_dir != direction:
		change_direction(throw_dir)

	# Convert angle to radians
	var angle_rad = deg_to_rad(throw_angle)
	var gravity = get_global_gravity()

	# Calculate required initial velocity using ballistic trajectory formula
	# v0^2 = g * dx^2 / (2 * cos^2(θ) * (dx * tan(θ) - dy))
	var tan_angle = tan(angle_rad)
	var cos_angle = cos(angle_rad)

	var denominator = dx * tan_angle - dy

	# Check if trajectory is possible
	if denominator <= 0:
		# Target is too high or trajectory impossible, use fallback
		denominator = dx * tan_angle  # Assume target at same height

	var v0_squared = (gravity * dx * dx) / (2.0 * cos_angle * cos_angle * denominator)

	# Check for valid velocity
	if v0_squared <= 0:
		v0_squared = 300.0 * 300.0  # Fallback velocity

	var v0 = sqrt(v0_squared)

	# Calculate velocity components
	var vx = v0 * cos_angle * throw_dir
	var vy = -v0 * sin(angle_rad)  # Negative because throwing upward

	coconut.linear_velocity = Vector2(vx, vy)

	print("[Throw] Target: (%.0f, %.0f), Distance: %.0f, Angle: %.1f°, v0: %.1f, vx: %.1f, vy: %.1f" %
		[target_pos.x, target_pos.y, dx, throw_angle, v0, vx, vy])

func get_global_gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") as float
