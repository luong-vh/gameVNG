extends AnimatableBody2D
class_name ToggleableTerrainPlatform

## Platform làm từ terrain tiles có thể bật/tắt bởi lever
## Sử dụng TileMapLayer để vẽ các cục đất

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
@onready var tilemap: TileMapLayer = $TileMapLayer if has_node("TileMapLayer") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

# Load tileset
const TILESET_PATH = "res://assets/island/tileset.tres"


func _ready() -> void:
	print("[ToggleableTerrainPlatform] ", name, " _ready()")

	# Debug tilemap
	if tilemap:
		print("  - TileMapLayer found!")

		# FIX: Reassign tileset if null
		if tilemap.tile_set == null:
			print("  - WARNING: tile_set is null! Loading from path...")
			var loaded_tileset = load(TILESET_PATH)
			if loaded_tileset:
				tilemap.tile_set = loaded_tileset
				print("  - ✅ TileSet loaded successfully!")
			else:
				push_error("  - ❌ Failed to load tileset from: ", TILESET_PATH)

		# IMPORTANT: Disable TileMap collision (we use our own CollisionShape2D)
		tilemap.collision_enabled = false
		print("  - TileMap collision_enabled set to: ", tilemap.collision_enabled)
	else:
		print("  - WARNING: TileMapLayer is NULL!")

	# Debug collision
	if collision_shape:
		print("  - CollisionShape2D found!")
		print("  - collision_shape type: ", collision_shape.get_class())
		print("  - collision_shape.shape: ", collision_shape.shape)
	else:
		print("  - WARNING: CollisionShape2D is NULL!")

	# Set initial state
	if start_active:
		_set_active_immediate(true)
	else:
		_set_active_immediate(false)


## Public methods

func activate() -> void:
	"""Kích hoạt platform (xuất hiện)"""
	if is_active:
		return

	print("[ToggleableTerrainPlatform] Activating platform: ", name)
	is_active = true

	# Show tilemap
	if tilemap:
		tilemap.visible = true
		print("  - tilemap.visible = true")

	# Enable manual collision shape
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
		print("  - collision_shape.disabled = false (collision ENABLED)")
	else:
		print("  - WARNING: collision_shape is NULL!")

	platform_activated.emit()


func deactivate() -> void:
	"""Hủy kích hoạt platform (biến mất)"""
	if not is_active:
		return

	print("[ToggleableTerrainPlatform] Deactivating platform: ", name)
	is_active = false

	# Hide tilemap and disable collision
	if tilemap:
		tilemap.visible = false
		print("  - tilemap.visible = false")

	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		print("  - collision_shape.disabled = true (collision DISABLED)")
	else:
		print("  - WARNING: collision_shape is NULL!")

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
	print("[ToggleableTerrainPlatform] ", name, " _set_active_immediate(", active, ")")
	is_active = active

	if tilemap:
		tilemap.visible = active
		print("  - tilemap.visible set to: ", active)

	if collision_shape:
		collision_shape.set_deferred("disabled", not active)
		print("  - collision disabled set to: ", not active)


func _fade_in() -> void:
	"""Fade in animation"""
	if not tilemap:
		is_transitioning = false
		return

	print("[ToggleableTerrainPlatform] _fade_in() starting")
	print("  - Current tilemap.modulate: ", tilemap.modulate)
	print("  - Target active_modulate: ", active_modulate)
	print("  - fade_duration: ", fade_duration)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tilemap, "modulate", active_modulate, fade_duration)
	tween.finished.connect(_on_fade_in_finished)


func _fade_out() -> void:
	"""Fade out animation"""
	if not tilemap:
		is_transitioning = false
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		return

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(tilemap, "modulate", inactive_modulate, fade_duration)
	tween.finished.connect(_on_fade_out_finished)


func _on_fade_in_finished() -> void:
	is_transitioning = false
	print("[ToggleableTerrainPlatform] Fade in complete: ", name)
	print("  - Final tilemap.modulate: ", tilemap.modulate if tilemap else "NULL")
	print("  - tilemap.visible: ", tilemap.visible if tilemap else "NULL")


func _on_fade_out_finished() -> void:
	# Disable collision after fade out complete
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	is_transitioning = false
	print("[ToggleableTerrainPlatform] Fade out complete: ", name)
