extends Node2D
class_name Seesaw

## Export variables
@export var max_rotation_angle: float = 30.0  ## Góc xoay tối đa (độ)
@export var rotation_speed: float = 0.3  ## Tốc độ xoay (giây)

## Signals
signal tilted_left(angle: float)
signal tilted_right(angle: float)
signal balanced()

## State
var bodies_on_plank: Array[Node2D] = []  ## Tất cả bodies trên plank
var current_tilt_direction: int = 0  ## -1 (trái), 0 (cân bằng), 1 (phải)
var active_tween: Tween = null  ## Để kill tween cũ, tránh giật

## Node references
@onready var plank: AnimatableBody2D = $Plank
@onready var left_detector: Area2D = $Plank/LeftDetector
@onready var right_detector: Area2D = $Plank/RightDetector


func _ready() -> void:
	print("[Seesaw] Initialized!")

	# Connect cả 2 detectors - nhưng đều add vào cùng array
	left_detector.body_entered.connect(_on_body_entered)
	left_detector.body_exited.connect(_on_body_exited)
	right_detector.body_entered.connect(_on_body_entered)
	right_detector.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	print("[Seesaw] Body entered plank: ", body.name)
	if body not in bodies_on_plank:
		bodies_on_plank.append(body)


func _on_body_exited(body: Node2D) -> void:
	print("[Seesaw] Body exited plank: ", body.name)
	if body in bodies_on_plank:
		bodies_on_plank.erase(body)


func _physics_process(_delta: float) -> void:
	# Update rotation mỗi frame dựa vào vị trí của bodies
	_update_rotation()


func _update_rotation() -> void:
	# Đếm bodies mỗi bên dựa vào VỊ TRÍ X so với pivot
	var pivot_x = global_position.x  # Vị trí X của pivot (root node)
	var left_count = 0
	var right_count = 0

	for body in bodies_on_plank:
		if not is_instance_valid(body):
			continue

		var body_x = body.global_position.x
		if body_x < pivot_x - 4:  # Bên trái (thêm dead zone 4px ở giữa)
			left_count += 1
		elif body_x > pivot_x + 4:  # Bên phải
			right_count += 1
		# Nếu trong khoảng -4 đến +4 (ở giữa) → không tính

	# Tính hướng nghiêng
	var new_tilt_direction = 0
	if left_count > right_count:
		new_tilt_direction = -1  # Nghiêng trái
	elif right_count > left_count:
		new_tilt_direction = 1  # Nghiêng phải
	else:
		new_tilt_direction = 0  # Cân bằng

	# Chỉ update nếu direction thay đổi (giảm spam tween)
	if new_tilt_direction != current_tilt_direction:
		print("[Seesaw] Bodies - Left: ", left_count, " | Right: ", right_count)
		print("[Seesaw] Direction changed: ", current_tilt_direction, " → ", new_tilt_direction)

		current_tilt_direction = new_tilt_direction

		# Tính góc xoay (radians)
		var target_rotation = deg_to_rad(new_tilt_direction * max_rotation_angle)

		# Kill tween cũ để tránh giật
		if active_tween and active_tween.is_running():
			active_tween.kill()

		# Animate rotation
		active_tween = create_tween()
		active_tween.set_ease(Tween.EASE_OUT)
		active_tween.set_trans(Tween.TRANS_CUBIC)
		active_tween.tween_property(plank, "rotation", target_rotation, rotation_speed)

		# Emit signals
		_emit_state_signals()


func _emit_state_signals() -> void:
	if current_tilt_direction == 0:
		print("[Seesaw] BALANCED")
		balanced.emit()
	elif current_tilt_direction < 0:
		print("[Seesaw] TILTED LEFT")
		tilted_left.emit(max_rotation_angle)
	else:
		print("[Seesaw] TILTED RIGHT")
		tilted_right.emit(max_rotation_angle)


## Public methods
func get_tilt_direction() -> int:
	"""Trả về: -1 (trái), 0 (cân bằng), 1 (phải)"""
	return current_tilt_direction


func is_balanced() -> bool:
	"""Kiểm tra có cân bằng không"""
	return current_tilt_direction == 0


func reset() -> void:
	"""Reset về trạng thái ban đầu"""
	bodies_on_plank.clear()
	current_tilt_direction = 0

	# Kill tween đang chạy
	if active_tween and active_tween.is_running():
		active_tween.kill()

	plank.rotation = 0.0
	print("[Seesaw] Reset to balanced state")
