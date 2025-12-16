extends Area2D
class_name BaseCollectible

## Base class for all collectible items with save/load support

signal interacted
signal interaction_available
signal interaction_unavailable

@export_group("Save Settings")
@export var object_id: String = ""
@export var save_enabled: bool = true

@export_group("Collectible Settings")
@export var interact_input_action: String = ""
@export var is_attractable: bool = true

var collected: bool = false
var initial_state: Dictionary = {}
var scene_default_state: Dictionary = {}

func _ready() -> void:
	if object_id.is_empty():
		object_id = "%s_%s" % [get_parent().name if get_parent() else "root", name]

	_save_initial_state()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interact_input_action.is_empty():
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(false)

	add_to_group("collectibles")
	interaction_available.connect(_on_collect)


func _unhandled_input(event):
	if interact_input_action and event.is_action_pressed(interact_input_action):
		interacted.emit()
		var viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _on_body_entered(_body: Node2D) -> void:
	if collected:
		return

	if not interact_input_action.is_empty():
		set_process_unhandled_input(true)

	interaction_available.emit.call_deferred()

func _on_body_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	interaction_unavailable.emit.call_deferred()

func _on_collect() -> void:
	if collected:
		return

	collected = true
	visible = false
	monitoring = false

func _on_interacted_by_player() -> void:
	pass

func _save_initial_state() -> void:
	var state = get_state()
	initial_state = state
	scene_default_state = state.duplicate()

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

func reset_to_scene_default() -> void:
	if not scene_default_state.is_empty():
		set_state(scene_default_state)

func confirm_current_state() -> void:
	initial_state = get_state()
