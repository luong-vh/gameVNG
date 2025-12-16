extends SaveableObject
class_name LeverControl

@onready var levers_node = $Levers
@onready var torches_node = $Torches
@onready var doors_node = $Doors

func _ready():
	super._ready()

	for lever in levers_node.get_children():
		if lever.has_signal("activated"):
			lever.activated.connect(_on_activated)
	
	await get_tree().process_frame
	_update_all()

func _on_activated(_is_activate: bool):
	_update_all()

func _update_all():
	var active_count := _count_active_levers()
	_update_torches(active_count)
	_update_doors(active_count)

func _count_active_levers() -> int:
	var count := 0
	for lever in levers_node.get_children():
		if lever.get("is_activated") != null and lever.is_activated:
			count += 1
	return count

func _update_torches(active_count: int):
	var torches := torches_node.get_children()
	
	for i in torches.size():
		if i < active_count:
			torches[i].turn_on()
		else:
			torches[i].turn_off()

func _update_doors(active_count: int):
	if active_count == levers_node.get_child_count():
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

func set_state(_state: Dictionary) -> void:
	_update_all()
