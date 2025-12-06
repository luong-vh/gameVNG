class_name BaseCollectible
extends Area2D

## Base class for all collectible items.
## Handles common setup like interaction signals and provides a virtual method for collection logic.

#signal when player interact with the area
signal interacted

#signal when player can interact with the area
signal interaction_available

#signal when player can't interact with the area
signal interaction_unavailable

@export var interact_input_action: String = ""  # Empty = auto-collect, set value = require input
@export var is_attractable: bool = true
var collected: bool


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Only enable input if interact_input_action is set
	if interact_input_action.is_empty():
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(false)  # Will be enabled on body_entered

	add_to_group("collectibles")
	# Connect interaction_available signal to a virtual method for collection
	# This is suitable for items collected simply by touching/being in range
	interaction_available.connect(_on_collect)


func _unhandled_input(event):
	if interact_input_action and event.is_action_pressed(interact_input_action):
		interacted.emit()
		var viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _on_body_entered(_body: Node2D) -> void:
	# Only enable input if interact_input_action is set (for items like chests)
	if not interact_input_action.is_empty():
		set_process_unhandled_input(true)
	# Use call_deferred to avoid "blocked during in/out signal" error
	interaction_available.emit.call_deferred()


func _on_body_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	# Use call_deferred to avoid "blocked during in/out signal" error
	interaction_unavailable.emit.call_deferred()


func _on_collect() -> void:
	collected = true

func _on_interacted_by_player() -> void:
	# This is a virtual method to be overridden by derived classes.
	# Contains the specific logic for what happens when the item is interacted with (e.g., pressing 'interact' key).
	pass
