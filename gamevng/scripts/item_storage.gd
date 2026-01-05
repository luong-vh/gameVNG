extends RefCounted
class_name ItemStorage

# Signals for UI updates
signal hotbar_updated(slot_index: int, texture: Texture2D, count: int)
signal hotbar_cleared(slot_index: int)
signal inventory_updated(slot_index: int, texture: Texture2D, count: int)
signal inventory_cleared(slot_index: int)

# Storage arrays
var hotbar_items: Array[ItemData] = []
var inventory_items: Array[ItemData] = []

# Configuration
var hotbar_size: int = 5
var inventory_size: int = 15

# ==================== Initialization ====================

func initialize() -> void:
	initialize_hotbar()
	initialize_inventory()

func initialize_hotbar() -> void:
	hotbar_items.clear()
	for i in range(hotbar_size):
		hotbar_items.append(null)

func initialize_inventory() -> void:
	inventory_items.clear()
	for i in range(inventory_size):
		inventory_items.append(null)

# ==================== Hotbar Operations ====================

func add_item_to_hotbar(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	for i in range(hotbar_items.size()):
		var item = hotbar_items[i]
		if item != null and item.item_name == item_name:
			var can_add = min(count, item.max_stack - item.count)
			if can_add > 0:
				item.count += can_add
				hotbar_updated.emit(i, item.texture, item.count)
				count -= can_add
				if count <= 0:
					return true

	# Find empty slot
	for i in range(hotbar_items.size()):
		if hotbar_items[i] == null:
			var new_item = ItemData.new(item_name, texture, count)
			hotbar_items[i] = new_item
			hotbar_updated.emit(i, new_item.texture, new_item.count)
			return true

	# Hotbar is full
	print("[ItemStorage] Hotbar is full!")
	return false

func get_hotbar_item(slot_index: int) -> ItemData:
	if slot_index >= 0 and slot_index < hotbar_items.size():
		return hotbar_items[slot_index]
	return null

func set_hotbar_slot(slot_index: int, item_name: String, texture: Texture2D, count: int = 1) -> bool:
	if slot_index < 0 or slot_index >= hotbar_items.size():
		return false

	var new_item = ItemData.new(item_name, texture, count)
	hotbar_items[slot_index] = new_item
	hotbar_updated.emit(slot_index, new_item.texture, new_item.count)
	return true

func clear_hotbar_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < hotbar_items.size():
		hotbar_items[slot_index] = null
		hotbar_cleared.emit(slot_index)

func clear_hotbar() -> void:
	for i in range(hotbar_items.size()):
		hotbar_items[i] = null
		hotbar_cleared.emit(i)

func use_item_from_hotbar(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= hotbar_items.size():
		return false

	var item = hotbar_items[slot_index]
	if item == null or item.count <= 0:
		return false

	item.count -= 1

	if item.count <= 0:
		hotbar_items[slot_index] = null
		hotbar_cleared.emit(slot_index)
	else:
		hotbar_updated.emit(slot_index, item.texture, item.count)

	return true

# ==================== Inventory Operations ====================

func add_item_to_inventory(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	# Try to stack with existing item first
	for i in range(inventory_items.size()):
		var item = inventory_items[i]
		if item != null and item.item_name == item_name:
			var can_add = min(count, item.max_stack - item.count)
			if can_add > 0:
				item.count += can_add
				inventory_updated.emit(i, item.texture, item.count)
				count -= can_add
				if count <= 0:
					return true

	# Find empty slot
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			var new_item = ItemData.new(item_name, texture, count)
			inventory_items[i] = new_item
			inventory_updated.emit(i, new_item.texture, new_item.count)
			return true

	print("[ItemStorage] Inventory is full!")
	return false

func get_inventory_item(slot_index: int) -> ItemData:
	if slot_index >= 0 and slot_index < inventory_items.size():
		return inventory_items[slot_index]
	return null

func set_inventory_slot(slot_index: int, item_name: String, texture: Texture2D, count: int = 1) -> bool:
	if slot_index < 0 or slot_index >= inventory_items.size():
		return false

	var new_item = ItemData.new(item_name, texture, count)
	inventory_items[slot_index] = new_item
	inventory_updated.emit(slot_index, new_item.texture, new_item.count)
	return true

func clear_inventory_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < inventory_items.size():
		inventory_items[slot_index] = null
		inventory_cleared.emit(slot_index)

func clear_inventory() -> void:
	for i in range(inventory_items.size()):
		inventory_items[i] = null
		inventory_cleared.emit(i)
	print("[ItemStorage] Cleared all inventory slots")

func use_item_from_inventory(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= inventory_items.size():
		return false

	var item = inventory_items[slot_index]
	if item == null or item.count <= 0:
		return false

	item.count -= 1

	if item.count <= 0:
		inventory_items[slot_index] = null
		inventory_cleared.emit(slot_index)
	else:
		inventory_updated.emit(slot_index, item.texture, item.count)

	return true
