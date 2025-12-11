extends Node2D
class_name SaveableObject

@export_group("Save Settings")
@export var object_id: String = "" 
@export var save_enabled: bool = true  

var initial_state: Dictionary = {}

func _ready():
	if object_id.is_empty():
		object_id = "%s_%s" % [get_parent().name, name]
		
	call_deferred("_save_initial_state")

func _save_initial_state():
	initial_state = get_state()

func get_state() -> Dictionary:
	return {
		"pos_x": position.x,
		"pos_y": position.y,
		"visible": visible
	}

func set_state(state: Dictionary) -> void:
	if state.has("pos_x") and state.has("pos_y"):
		position = Vector2(state.pos_x, state.pos_y)
	if state.has("visible"):
		visible = state.visible

func reset_to_initial() -> void:
	if not initial_state.is_empty():
		set_state(initial_state)
