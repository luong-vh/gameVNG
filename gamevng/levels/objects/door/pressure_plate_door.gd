extends Node2D
class_name PressurePlateDoor

## Loại cửa
enum DoorType {
	TOGGLE,     ## Mở/đóng khi activate/deactivate
	PERMANENT   ## Mở một lần rồi không đóng nữa
}

## Export variables
@export var door_type: DoorType = DoorType.TOGGLE
@export var disable_collision_when_open: bool = true  ## Tắt collision khi cửa mở
@export var animation_duration: float = 1.0  ## Thời gian animation (giây)

## Signals
signal door_opened
signal door_closed

## State
var is_open: bool = false

## Node references
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $AnimatableBody2D/CollisionShape2D
@onready var platform_path: Path2D = $PlatformPath2D


func _ready() -> void:
	print("[PressurePlateDoor] Initialized! Type: ", door_type)

	# Set animation speed based on duration
	if animation_player:
		if animation_player.has_animation("open"):
			var anim = animation_player.get_animation("open")
			anim.length = animation_duration
		if animation_player.has_animation("close"):
			var anim = animation_player.get_animation("close")
			anim.length = animation_duration

	# Set initial state
	_update_collision_state()


func open() -> void:
	"""Mở cửa"""
	if is_open and door_type == DoorType.PERMANENT:
		print("[PressurePlateDoor] Already open (PERMANENT mode)")
		return

	print("[PressurePlateDoor] Opening door...")
	is_open = true

	# Play animation
	if animation_player and animation_player.has_animation("open"):
		animation_player.play("open")

	# Update collision
	_update_collision_state()

	# Emit signal
	door_opened.emit()


func close() -> void:
	"""Đóng cửa"""
	# Không đóng nếu là PERMANENT mode
	if door_type == DoorType.PERMANENT:
		print("[PressurePlateDoor] PERMANENT mode - Cannot close")
		return

	if not is_open:
		print("[PressurePlateDoor] Door already closed")
		return

	print("[PressurePlateDoor] Closing door...")
	is_open = false

	# Play animation
	if animation_player and animation_player.has_animation("close"):
		animation_player.play("close")

	# Update collision
	_update_collision_state()

	# Emit signal
	door_closed.emit()


func _update_collision_state() -> void:
	"""Cập nhật collision dựa trên state"""
	if not collision_shape:
		return

	if disable_collision_when_open:
		collision_shape.disabled = is_open
		print("[PressurePlateDoor] Collision disabled: ", is_open)


func toggle() -> void:
	"""Toggle cửa mở/đóng"""
	if is_open:
		close()
	else:
		open()


func reset() -> void:
	"""Reset về trạng thái ban đầu (đóng)"""
	is_open = false
	if animation_player:
		animation_player.play("RESET")
	_update_collision_state()
