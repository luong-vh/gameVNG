extends AnimatableBody2D
class_name ToggleablePlatform

## Platform có thể bật/tắt bởi lever hoặc trigger khác
## Khi tắt: platform biến mất (ẩn sprite + tắt collision)
## Khi bật: platform xuất hiện

## Export variables
@export_group("Toggle Settings")
@export var start_active: bool = true  ## Platform có active khi bắt đầu không
@export var fade_duration: float = 0.3  ## Thời gian fade in/out (giây)
@export var use_fade_effect: bool = true  ## Có dùng fade effect không

@export_group("Visual Feedback")
@export var inactive_modulate: Color = Color(1, 1, 1, 0.3)  ## Màu khi inactive (mờ)
@export var active_modulate: Color = Color(1, 1, 1, 1.0)  ## Màu khi active (đậm)

## Signals
signal platform_activated
signal platform_deactivated

## State
var is_active: bool = true
var is_transitioning: bool = false

## Node references
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null


func _ready() -> void:
	# Set initial state
	if start_active:
		_set_active_immediate(true)
	else:
		_set_active_immediate(false)


## Public methods

func activate() -> void:
	"""Kích hoạt platform (xuất hiện)"""
	if is_active or is_transitioning:
		return

	print("[ToggleablePlatform] Activating platform: ", name)
	is_transitioning = true
	is_active = true

	# Enable collision immediately
	if collision_shape:
		collision_shape.disabled = false

	# Fade in sprite
	if use_fade_effect and sprite:
		_fade_in()
	else:
		if sprite:
			sprite.modulate = active_modulate
		is_transitioning = false

	platform_activated.emit()


func deactivate() -> void:
	"""Hủy kích hoạt platform (biến mất)"""
	if not is_active or is_transitioning:
		return

	print("[ToggleablePlatform] Deactivating platform: ", name)
	is_transitioning = true
	is_active = false

	# Fade out sprite first, then disable collision
	if use_fade_effect and sprite:
		_fade_out()
	else:
		if sprite:
			sprite.modulate = inactive_modulate
		if collision_shape:
			collision_shape.disabled = true
		is_transitioning = false

	platform_deactivated.emit()


func toggle() -> void:
	"""Toggle platform bật/tắt"""
	if is_active:
		deactivate()
	else:
		activate()


func is_platform_active() -> bool:
	"""Kiểm tra platform có đang active không"""
	return is_active


## Private methods

func _set_active_immediate(active: bool) -> void:
	"""Set trạng thái ngay lập tức không có animation"""
	is_active = active

	if sprite:
		sprite.modulate = active_modulate if active else inactive_modulate

	if collision_shape:
		collision_shape.disabled = not active


func _fade_in() -> void:
	"""Fade in animation"""
	if not sprite:
		is_transitioning = false
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate", active_modulate, fade_duration)
	tween.finished.connect(_on_fade_in_finished)


func _fade_out() -> void:
	"""Fade out animation"""
	if not sprite:
		is_transitioning = false
		if collision_shape:
			collision_shape.disabled = true
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "modulate", inactive_modulate, fade_duration)
	tween.finished.connect(_on_fade_out_finished)


func _on_fade_in_finished() -> void:
	is_transitioning = false
	print("[ToggleablePlatform] Fade in complete: ", name)


func _on_fade_out_finished() -> void:
	# Disable collision after fade out complete
	if collision_shape:
		collision_shape.disabled = true
	is_transitioning = false
	print("[ToggleablePlatform] Fade out complete: ", name)
