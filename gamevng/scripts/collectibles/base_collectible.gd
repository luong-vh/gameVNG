extends Area2D
class_name BaseCollectible

## Base class for all collectible items.
## Handles common setup like interaction signals and provides a virtual method for collection logic.
## Now supports save/load system to persist collected state across checkpoints.

#signal when player interact with the area
signal interacted

#signal when player can interact with the area
signal interaction_available

#signal when player can't interact with the area
signal interaction_unavailable

@export_group("Save Settings")
@export var object_id: String = ""
@export var save_enabled: bool = true

@export_group("Collectible Settings")
@export var interact_input_action: String = ""  # Empty = auto-collect, set value = require input
@export var is_attractable: bool = true

var collected: bool = false
var initial_state: Dictionary = {}


func _ready() -> void:
	print("[BaseCollectible] %s ready - visible: %s, monitoring: %s, collected: %s" % [name, visible, monitoring, collected])

	# Setup object_id for save system
	if object_id.is_empty():
		object_id = "%s_%s" % [get_parent().name if get_parent() else "root", name]

	# Save initial state IMMEDIATELY to capture scene defaults BEFORE any interaction
	_save_initial_state()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("[BaseCollectible] %s - signals connected" % name)

	# Only enable input if interact_input_action is set
	if interact_input_action.is_empty():
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(false)  # Will be enabled on body_entered

	add_to_group("collectibles")
	# Connect interaction_available signal to a virtual method for collection
	# This is suitable for items collected simply by touching/being in range
	interaction_available.connect(_on_collect)
	print("[BaseCollectible] %s - interaction_available connected to _on_collect" % name)


func _unhandled_input(event):
	if interact_input_action and event.is_action_pressed(interact_input_action):
		interacted.emit()
		var viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _on_body_entered(_body: Node2D) -> void:
	print("[BaseCollectible] %s - body_entered: %s (collected: %s)" % [name, _body.name, collected])

	if collected:
		print("[BaseCollectible] %s - already collected, ignoring" % name)
		return

	# Only enable input if interact_input_action is set (for items like chests)
	if not interact_input_action.is_empty():
		set_process_unhandled_input(true)
	# Use call_deferred to avoid "blocked during in/out signal" error
	print("[BaseCollectible] %s - emitting interaction_available" % name)
	interaction_available.emit.call_deferred()


func _on_body_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	# Use call_deferred to avoid "blocked during in/out signal" error
	interaction_unavailable.emit.call_deferred()


func _on_collect() -> void:
	print("[BaseCollectible] %s - _on_collect() called! (collected: %s)" % [name, collected])

	if collected:
		print("[BaseCollectible] %s - already collected, skipping" % name)
		return  # Already collected, prevent double collection

	print("[BaseCollectible] %s - collecting now..." % name)
	collected = true
	visible = false  # Hide instead of queue_free to preserve for save/load
	monitoring = false  # Disable collision detection
	print("[BaseCollectible] %s - collected! (visible: %s, monitoring: %s)" % [name, visible, monitoring])

func _on_interacted_by_player() -> void:
	# This is a virtual method to be overridden by derived classes.
	# Contains the specific logic for what happens when the item is interacted with (e.g., pressing 'interact' key).
	pass


# ==================== Save/Load System ====================

func _save_initial_state() -> void:
	initial_state = get_state()

func get_state() -> Dictionary:
	return {
		"pos_x": position.x,
		"pos_y": position.y,
		"visible": visible,
		"collected": collected,
		"monitoring": monitoring
	}

func set_state(state: Dictionary) -> void:
	if state.has("pos_x") and state.has("pos_y"):
		position = Vector2(state.pos_x, state.pos_y)

	if state.has("visible"):
		visible = state.visible

	if state.has("collected"):
		collected = state.collected

	if state.has("monitoring"):
		monitoring = state.monitoring

func reset_to_initial() -> void:
	if not initial_state.is_empty():
		set_state(initial_state)

func confirm_current_state() -> void:
	# Called when checkpoint is activated
	# Update initial_state to current state (collected items stay collected)
	initial_state = get_state()
