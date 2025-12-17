extends SaveableObject

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow = $PlatformPath2D/PathFollow2D

var is_moved: bool = false
var is_movable: bool = true
var original_progress: float = 0.0

var state_locked: bool = false

@export var toggle_day_night_at_mid: bool = false
var has_toggled_day_night: bool = false

func _ready() -> void:
	await get_tree().process_frame
	if path_follow:
		original_progress = path_follow.progress
	super._ready()

func _process(_delta: float) -> void:
	if not toggle_day_night_at_mid or not path_follow:
		return

	var progress_ratio = path_follow.progress_ratio

	# Trigger khi đi qua midpoint (cross 0.3 threshold)
	if progress_ratio >= 0.3 and not has_toggled_day_night:
		DayNightManager.force_toggle_day_night()
		has_toggled_day_night = true
		print("[Boat] Force toggled day/night at progress: ", progress_ratio)
	elif progress_ratio < 0.1:
		has_toggled_day_night = false

func get_state() -> Dictionary:
	var state = super.get_state()
	if not state_locked:
		state["path_progress"] = original_progress
		state["is_moved"] = false
	else:
		state["path_progress"] = path_follow.progress if path_follow else original_progress
		state["is_moved"] = is_moved
	
	state["is_movable"] = is_movable
	state["original_progress"] = original_progress
	state["state_locked"] = state_locked
	return state

func set_state(state: Dictionary) -> void:
	super.set_state(state)
	
	if state.has("original_progress"):
		original_progress = state.original_progress
	
	if state.has("is_movable"):
		is_movable = state.is_movable
	
	if state.has("state_locked"):
		state_locked = state.state_locked
	
	if state.has("path_progress") and path_follow:
		path_follow.progress = state.path_progress
	
	if state.has("is_moved"):
		is_moved = state.is_moved

		if is_moved:
			if animation_player and animation_player.has_animation("move"):
				animation_player.play("move")
				animation_player.seek(animation_player.current_animation_length, true)
				animation_player.pause()
		else:
			if animation_player:
				animation_player.stop()

func confirm_current_state() -> void:
	"""Lock state hiện tại - được gọi từ checkpoint"""
	state_locked = true
	print("[Boat] State LOCKED: progress=%s, is_moved=%s" % [path_follow.progress if path_follow else 0, is_moved])

func _on_interactive_area_2d_interacted() -> void:
	if not is_movable:
		return

	# Check if player has steering wheel
	if not _has_steering_wheel():
		print("[Boat] Cần bánh lái để điều khiển thuyền!")
		return

	# Use steering wheel
	_use_steering_wheel()

	if not is_moved:
		animation_player.play("move")
		state_locked = false
	else:
		animation_player.play("return")
		state_locked = false

	is_moved = !is_moved

func _has_steering_wheel() -> bool:
	if not GameManager.inventory_system:
		return false

	# Check in hotbar
	for i in range(GameManager.inventory_system.hotbar_size):
		var item = GameManager.inventory_system.get_hotbar_item(i)
		if item and item.item_name == "steering_wheel":
			return true

	# Check in inventory
	for i in range(GameManager.inventory_system.inventory_size):
		var item = GameManager.inventory_system.get_inventory_item(i)
		if item and item.item_name == "steering_wheel":
			return true

	return false

func _use_steering_wheel():
	if not GameManager.inventory_system:
		return

	# Remove from hotbar first
	for i in range(GameManager.inventory_system.hotbar_size):
		var item = GameManager.inventory_system.get_hotbar_item(i)
		if item and item.item_name == "steering_wheel":
			GameManager.inventory_system.use_item_from_hotbar(i)
			print("[Boat] Đã sử dụng bánh lái từ hotbar!")
			return

	# Remove from inventory
	for i in range(GameManager.inventory_system.inventory_size):
		var item = GameManager.inventory_system.get_inventory_item(i)
		if item and item.item_name == "steering_wheel":
			GameManager.inventory_system.use_item_from_inventory(i)
			print("[Boat] Đã sử dụng bánh lái từ inventory!")
			return

func movable():
	is_movable = true

func unmovable():
	is_movable = false
