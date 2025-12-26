extends Control
class_name Hotbar

signal slot_selected(slot_index: int)
signal item_used(slot_index: int)

@export var slot_count: int = 5
@export var slot_size: Vector2 = Vector2(32, 32)
@export var slot_spacing: int = 8  # Increased from 4 to 8 for better separation

var slots: Array[HotbarSlot] = []
var selected_slot: int = 0

@onready var slots_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	create_slots()
	update_selected_slot()
	
func _unhandled_input(event: InputEvent) -> void:
	# Debug key to reset current level only
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		print("[Hotbar] *** RESETTING CURRENT LEVEL ONLY ***")
		GameManager.reset_level()
		get_viewport().set_input_as_handled()
		return

	# Handle number keys 1-5: SELECT AND USE ITEM IMMEDIATELY
	for i in range(slot_count):
		var key_code = KEY_1 + i
		if event is InputEventKey and event.pressed and event.keycode == key_code:
			select_slot(i)
			# Immediately try to use item in this slot
			item_used.emit(i)
			get_viewport().set_input_as_handled()
			return

	# Handle scroll wheel for slot selection ONLY (no use)
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				select_slot((selected_slot - 1) % slot_count)
				get_viewport().set_input_as_handled()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				select_slot((selected_slot + 1) % slot_count)
				get_viewport().set_input_as_handled()

func create_slots() -> void:
	# Clear existing slots
	for child in slots_container.get_children():
		child.queue_free()
	slots.clear()

	# Load slot scene
	var slot_scene = preload("res://scenes/gui/hotbar_slot.tscn")

	# Create new slots
	for i in range(slot_count):
		var slot = slot_scene.instantiate()
		slot.setup(i, slot_size)
		slot.slot_clicked.connect(_on_slot_clicked)
		slots.append(slot)
		slots_container.add_child(slot)

	# Set container spacing
	slots_container.add_theme_constant_override("separation", slot_spacing)

func select_slot(index: int) -> void:
	if index < 0 or index >= slot_count:
		return
		
	selected_slot = index
	update_selected_slot()
	slot_selected.emit(index)

func update_selected_slot() -> void:
	for i in range(slots.size()):
		slots[i].set_selected(i == selected_slot)

func set_slot_item(slot_index: int, texture: Texture2D, count: int = 1) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		slots[slot_index].set_item(texture, count)

func clear_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		slots[slot_index].clear_item()

func get_slot_count() -> int:
	return slot_count

func _on_slot_clicked(slot_index: int) -> void:
	var inv_sys = GameManager.inventory_system

	# Check if dragging from inventory
	if inv_sys.dragging_from_inventory:
		# Drop from inventory to hotbar
		inv_sys.move_item_inventory_to_hotbar(inv_sys.dragging_slot_index, slot_index)
		inv_sys.dragging_from_inventory = false
		inv_sys.dragging_slot_index = -1
		return

	# Handle hotbar drag & drop
	if not inv_sys.dragging_from_hotbar:
		# Start dragging
		var item = inv_sys.get_hotbar_item(slot_index)
		if item != null:
			inv_sys.dragging_from_hotbar = true
			inv_sys.dragging_slot_index = slot_index
			if slot_index < slots.size():
				slots[slot_index].set_dragging(true)
	else:
		# Drop within hotbar
		inv_sys.swap_hotbar_slots(inv_sys.dragging_slot_index, slot_index)

		# Clear dragging state
		if inv_sys.dragging_slot_index < slots.size():
			slots[inv_sys.dragging_slot_index].set_dragging(false)
		inv_sys.dragging_from_hotbar = false
		inv_sys.dragging_slot_index = -1
