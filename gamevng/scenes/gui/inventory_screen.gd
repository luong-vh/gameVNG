extends Control
class_name InventoryScreen

signal inventory_slot_clicked(slot_index: int)
signal item_dropped(slot_index: int)

@export var columns: int = 5
@export var rows: int = 3
@export var slot_size: Vector2 = Vector2(60, 60)
@export var slot_spacing: int = 15  # Increased from 4 to 8 for better separation

var total_slots: int = 15  # 3 rows x 5 columns
var slots: Array[InventorySlot] = []

@onready var slots_container: GridContainer = $Panel/MarginContainer/VBoxContainer/SlotsGrid

func _ready() -> void:
	# Hide by default
	visible = false

	# IMPORTANT: Make root node ignore mouse so it doesn't block hotbar
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Setup grid container
	slots_container.columns = columns

	# Create slots
	create_slots()

	# Connect to inventory system signals
	if GameManager.inventory_system:
		GameManager.inventory_system.inventory_updated.connect(_on_inventory_updated)
		GameManager.inventory_system.inventory_cleared.connect(_on_inventory_cleared)


func _unhandled_input(event: InputEvent) -> void:
	# Toggle inventory with Tab key
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_inventory()
		get_viewport().set_input_as_handled()

	# Close with ESC key
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide_inventory()
		get_viewport().set_input_as_handled()

func create_slots() -> void:
	# Clear existing slots
	for child in slots_container.get_children():
		child.queue_free()
	slots.clear()

	# Load slot scene
	var slot_scene = preload("res://scenes/gui/inventory_slot.tscn")

	# Create new slots
	for i in range(total_slots):
		var slot = slot_scene.instantiate()
		slot.setup(i, slot_size)
		slot.slot_clicked.connect(_on_slot_clicked)
		slots.append(slot)
		slots_container.add_child(slot)

	# Set spacing
	slots_container.add_theme_constant_override("h_separation", slot_spacing)
	slots_container.add_theme_constant_override("v_separation", slot_spacing)

func toggle_inventory() -> void:
	if visible:
		hide_inventory()
	else:
		show_inventory()

func show_inventory() -> void:
	visible = true
	refresh_inventory_display()

func hide_inventory() -> void:
	visible = false

func _on_slot_clicked(slot_index: int) -> void:
	var inv_sys = GameManager.inventory_system

	# Check if dragging from hotbar
	if inv_sys.dragging_from_hotbar:
		# Drop from hotbar to inventory
		inv_sys.move_item_hotbar_to_inventory(inv_sys.dragging_slot_index, slot_index)
		inv_sys.dragging_from_hotbar = false
		inv_sys.dragging_slot_index = -1
		return

	# Handle inventory drag & drop
	if not inv_sys.dragging_from_inventory:
		# Start dragging
		var item = inv_sys.get_inventory_item(slot_index)
		if item != null:
			inv_sys.dragging_from_inventory = true
			inv_sys.dragging_slot_index = slot_index
			if slot_index < slots.size():
				slots[slot_index].set_dragging(true)
	else:
		# Drop within inventory
		inv_sys.swap_inventory_slots(inv_sys.dragging_slot_index, slot_index)

		# Clear dragging state
		if inv_sys.dragging_slot_index < slots.size():
			slots[inv_sys.dragging_slot_index].set_dragging(false)
		inv_sys.dragging_from_inventory = false
		inv_sys.dragging_slot_index = -1

	inventory_slot_clicked.emit(slot_index)

func set_slot_item(slot_index: int, texture: Texture2D, count: int = 1) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		slots[slot_index].set_item(texture, count)

func clear_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		slots[slot_index].clear_item()

func get_slot_item_texture(slot_index: int) -> Texture2D:
	if slot_index >= 0 and slot_index < slots.size():
		return slots[slot_index].item_texture
	return null

func get_slot_item_count(slot_index: int) -> int:
	if slot_index >= 0 and slot_index < slots.size():
		return slots[slot_index].item_count
	return 0

func refresh_inventory_display() -> void:
	"""Refresh all inventory slots to match the InventorySystem data"""
	if not GameManager.inventory_system:
		return

	for i in range(total_slots):
		var item = GameManager.inventory_system.get_inventory_item(i)
		if item != null:
			set_slot_item(i, item.texture, item.count)
		else:
			clear_slot(i)


func _on_inventory_updated(slot_index: int, texture: Texture2D, count: int) -> void:
	"""Called when an inventory slot is updated in the system"""
	set_slot_item(slot_index, texture, count)

func _on_inventory_cleared(slot_index: int) -> void:
	"""Called when an inventory slot is cleared in the system"""
	clear_slot(slot_index)
