extends Node2D
class_name PressurePlate

## Loại kích hoạt
enum ActivationType {
	TOGGLE,     ## Đạp một lần bật, đạp lại tắt
	HOLD,       ## Giữ mới active, thả ra deactivate
	PERMANENT   ## Đạp một lần, active mãi mãi
}

### Export variables
@export var activation_type: ActivationType = ActivationType.HOLD

## Signals
signal activated(activator: Node2D)
signal deactivated(activator: Node2D)
signal toggled(is_active: bool)

## State
var is_active: bool = false
var bodies_on_plate: Array[Node2D] = []
var pending_activation: Node2D = null
var pending_deactivation: Node2D = null
var is_animating: bool = false

## Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Connect signals
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	# Connect animation finished signal
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if body not in bodies_on_plate:
		bodies_on_plate.append(body)
	
	# Activate when first body enters
	if bodies_on_plate.size() == 1:
		_start_activation(body)

func _on_body_exited(body: Node2D) -> void:
	# Remove body from tracking list
	if body in bodies_on_plate:
		bodies_on_plate.erase(body)
	
	# Deactivate when last body leaves
	if bodies_on_plate.size() == 0:
		_start_deactivation(body)

func _start_activation(activator: Node2D) -> void:
	var should_activate = false
	
	match activation_type:
		ActivationType.TOGGLE:
			should_activate = !is_active
		ActivationType.HOLD:
			should_activate = !is_active
		ActivationType.PERMANENT:
			should_activate = !is_active  # Only activate once
	
	if should_activate and not is_animating:
		is_animating = true
		pending_activation = activator
		if animation_player and animation_player.has_animation("press"):
			animation_player.play("press")
		else:
			# No animation, activate immediately
			_finish_activation()

func _start_deactivation(activator: Node2D) -> void:
	# Only deactivate for HOLD type
	if activation_type == ActivationType.HOLD and is_active and not is_animating:
		is_animating = true
		pending_deactivation = activator
		if animation_player and animation_player.has_animation("unpress"):
			animation_player.play("unpress")
		else:
			# No animation, deactivate immediately
			_finish_deactivation()

func _on_animation_finished(anim_name: String) -> void:
	is_animating = false
	
	if anim_name == "press" and pending_activation:
		_finish_activation()
	elif anim_name == "unpress" and pending_deactivation:
		_finish_deactivation()

func _finish_activation() -> void:
	print("[PressurePlate] Activated")
	if pending_activation:
		is_active = true
		activated.emit(pending_activation)
		toggled.emit(is_active)
		pending_activation = null

func _finish_deactivation() -> void:
	print("[PressurePlate] Deactivated")
	if pending_deactivation:
		is_active = false
		deactivated.emit(pending_deactivation)
		toggled.emit(is_active)
		pending_deactivation = null

## Public methods để force activate/deactivate từ code
func force_activate() -> void:
	if not is_active and not is_animating:
		_start_activation(self)

func force_deactivate() -> void:
	if is_active and activation_type != ActivationType.PERMANENT and not is_animating:
		_start_deactivation(self)

func reset() -> void:
	"""Reset về trạng thái ban đầu"""
	is_active = false
	bodies_on_plate.clear()
	pending_activation = null
	pending_deactivation = null
	is_animating = false
	
	if animation_player and animation_player.has_animation("unpress"):
		animation_player.play("unpress")
