extends SaveableObject

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow = $PlatformPath2D/PathFollow2D

var is_moved: bool = false
var is_movable: bool = true
var original_progress: float = 0.0

var state_locked: bool = false

func _ready() -> void:
	await get_tree().process_frame
	if path_follow:
		original_progress = path_follow.progress
	super._ready()

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
	
	if not is_moved:
		animation_player.play("move")
		state_locked = false
	else:
		animation_player.play("return")
		state_locked = false
	
	is_moved = !is_moved

func movable():
	is_movable = true

func unmovable():
	is_movable = false
