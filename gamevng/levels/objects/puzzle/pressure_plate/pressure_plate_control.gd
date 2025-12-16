extends SaveableObject
class_name PressurePlateControl

@onready var plates_node = $PressurePlates
@onready var torches_node = $Torches
@onready var doors_node = $Doors

func _ready() -> void:
	super._ready()

	for plate in plates_node.get_children():
		if plate.has_signal("toggled"):
			plate.toggled.connect(_on_plate_toggled)

	await get_tree().process_frame
	_update_all()

func _on_plate_toggled(_is_active: bool) -> void:
	_update_all()

func _update_all() -> void:
	var active_count := _count_active_plates()
	_update_torches(active_count)
	_update_doors(active_count)

func _count_active_plates() -> int:
	var count := 0
	for plate in plates_node.get_children():
		if plate.get("is_activated") != null and plate.is_activated:
			count += 1
	return count

func _update_torches(active_count: int) -> void:
	var torches := torches_node.get_children()

	for i in torches.size():
		if i < active_count:
			if torches[i].has_method("turn_on"):
				torches[i].turn_on()
		else:
			if torches[i].has_method("turn_off"):
				torches[i].turn_off()

func _update_doors(active_count: int) -> void:
	if active_count == plates_node.get_child_count():
		open_doors()
	else:
		close_doors()

func open_doors() -> void:
	for door in doors_node.get_children():
		if door.has_method("open"):
			door.open()

func close_doors() -> void:
	for door in doors_node.get_children():
		if door.has_method("close"):
			door.close()

func get_state() -> Dictionary:
	return {}

func set_state(_state: Dictionary) -> void:
	_update_all()
