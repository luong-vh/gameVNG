extends Node2D
class_name PressurePlate

## Loại kích hoạt
enum ActivationType {
	TOGGLE,     ## Đạp một lần bật, đạp lại tắt
	HOLD,       ## Giữ mới active, thả ra deactivate
	PERMANENT   ## Đạp một lần, active mãi mãi
}

## Export variables
@export var activation_type: ActivationType = ActivationType.HOLD
@export var pressed_frame: int = 1  ## Frame index khi pressed
@export var unpressed_frame: int = 0  ## Frame index khi unpressed
@export var press_depth: float = 2.0  ## Khoảng cách đi xuống khi đạp (pixels)
@export var animation_speed: float = 0.1  ## Tốc độ animation (giây)

## Signals
signal activated(activator: Node2D)
signal deactivated(activator: Node2D)
signal toggled(is_active: bool)

## State
var is_active: bool = false
var bodies_on_plate: Array[Node2D] = []
var initial_sprite_position: Vector2  ## Vị trí ban đầu của sprite

## Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	print("[PressurePlate] Initialized! Mode: ", activation_type)

	# Lưu vị trí ban đầu của sprite
	initial_sprite_position = sprite.position

	# Connect signals
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

	# Set initial visual state
	_update_visual_state()


func _on_body_entered(body: Node2D) -> void:
	print("[PressurePlate] Body entered: ", body.name)

	# Nếu vào đây nghĩa là đã match collision mask rồi!
	# Add body to tracking list
	if body not in bodies_on_plate:
		bodies_on_plate.append(body)

	# Activate when first body enters
	if bodies_on_plate.size() == 1:
		print("[PressurePlate] First body on plate, activating...")
		_activate(body)


func _on_body_exited(body: Node2D) -> void:
	print("[PressurePlate] Body exited: ", body.name)

	# Remove body from tracking list
	if body in bodies_on_plate:
		bodies_on_plate.erase(body)
		print("[PressurePlate] Removed from tracking. Bodies left: ", bodies_on_plate.size())

	# Deactivate when last body leaves
	if bodies_on_plate.size() == 0:
		print("[PressurePlate] No bodies left, deactivating...")
		_deactivate(body)


func _activate(activator: Node2D) -> void:
	var previous_state = is_active
	print("[PressurePlate] _activate() called. Previous state: ", previous_state)

	match activation_type:
		ActivationType.TOGGLE:
			is_active = !is_active
			print("[PressurePlate] TOGGLE mode - New state: ", is_active)
		ActivationType.HOLD:
			is_active = true
			print("[PressurePlate] HOLD mode - Set to active")
		ActivationType.PERMANENT:
			if not is_active:  # Only activate once
				is_active = true
				print("[PressurePlate] PERMANENT mode - Activated permanently")

	# Update visuals
	_update_visual_state()

	# Emit signals only if state changed
	if is_active != previous_state:
		if is_active:
			print("[PressurePlate] ✓ Emitting 'activated' signal!")
			activated.emit(activator)
		print("[PressurePlate] ✓ Emitting 'toggled' signal with state: ", is_active)
		toggled.emit(is_active)


func _deactivate(activator: Node2D) -> void:
	var previous_state = is_active
	print("[PressurePlate] _deactivate() called. Previous state: ", previous_state)

	# Only deactivate for HOLD type
	if activation_type == ActivationType.HOLD:
		is_active = false
		print("[PressurePlate] HOLD mode - Deactivated")
		_update_visual_state()

		if is_active != previous_state:
			print("[PressurePlate] ✓ Emitting 'deactivated' signal!")
			deactivated.emit(activator)
			print("[PressurePlate] ✓ Emitting 'toggled' signal with state: ", is_active)
			toggled.emit(is_active)
	else:
		print("[PressurePlate] Mode is ", activation_type, " - Not deactivating")


func _update_visual_state() -> void:
	# Update sprite frame
	if sprite and sprite.texture:
		sprite.frame = pressed_frame if is_active else unpressed_frame

	# Animate sprite position (di chuyển xuống khi pressed)
	var target_position = initial_sprite_position
	if is_active:
		target_position.y += press_depth  # Di xuống

	# Tween animation mượt mà
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "position", target_position, animation_speed)

	# Play animation if available (optional - nếu có AnimationPlayer)
	if animation_player:
		if is_active:
			if animation_player.has_animation("press"):
				animation_player.play("press")
		else:
			if animation_player.has_animation("unpress"):
				animation_player.play("unpress")


## Public methods để force activate/deactivate từ code
func force_activate() -> void:
	if not is_active:
		is_active = true
		_update_visual_state()
		activated.emit(self)
		toggled.emit(is_active)


func force_deactivate() -> void:
	if is_active and activation_type != ActivationType.PERMANENT:
		is_active = false
		_update_visual_state()
		deactivated.emit(self)
		toggled.emit(is_active)


func reset() -> void:
	"""Reset về trạng thái ban đầu"""
	is_active = false
	bodies_on_plate.clear()
	_update_visual_state()
