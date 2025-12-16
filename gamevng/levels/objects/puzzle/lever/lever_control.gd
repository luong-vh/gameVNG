extends SaveableObject
class_name LeverControl

@onready var levers_node = $Levers
@onready var doors_node = $Doors

func _ready():
	super._ready()
	
	# Connect to all levers in the Levers node
	for lever in levers_node.get_children():
		if lever.has_signal("lever_hitted"):
			lever.lever_hitted.connect(_on_lever_hitted)
		else:
			push_warning("Lever missing 'lever_hitted' signal: " + lever.name)
	
	# Check initial state
	check_all_levers_activated()

func _on_lever_hitted(is_activate: bool):
	# Check lever states whenever any lever is hit
	check_all_levers_activated()

func check_all_levers_activated():
	var all_active = true
	for lever in levers_node.get_children():
		if lever.has("activated") and not lever.activated:
			all_active = false
			break
	
	if all_active:
		open_doors()
	else:
		close_doors()

func open_doors():
	for door in doors_node.get_children():
		if door.has_method("open"):
			door.open()

func close_doors():
	for door in doors_node.get_children():
		if door.has_method("close"):
			door.close()

func get_state() -> Dictionary:
	return {}

func set_state(state: Dictionary) -> void:
	check_all_levers_activated()
