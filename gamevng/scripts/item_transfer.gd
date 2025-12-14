extends RefCounted
class_name ItemTransfer

var storage: ItemStorage

func _init(item_storage: ItemStorage):
	storage = item_storage

# ==================== Hotbar <-> Inventory Transfers ====================

func move_item_hotbar_to_inventory(hotbar_slot: int, inventory_slot: int) -> bool:
	"""Move item from hotbar to inventory. If items are the same type, stack them."""
	if hotbar_slot < 0 or hotbar_slot >= storage.hotbar_items.size():
		return false
	if inventory_slot < 0 or inventory_slot >= storage.inventory_items.size():
		return false

	var hotbar_item = storage.hotbar_items[hotbar_slot]
	if hotbar_item == null:
		return false

	var inventory_item = storage.inventory_items[inventory_slot]

	# Check if both slots have items and are the same type
	if inventory_item != null and hotbar_item.item_name == inventory_item.item_name:
		# Same item type - try to stack them
		var total_count = hotbar_item.count + inventory_item.count

		if total_count <= inventory_item.max_stack:
			# Can merge all into inventory slot
			inventory_item.count = total_count
			storage.hotbar_items[hotbar_slot] = null
			storage.hotbar_cleared.emit(hotbar_slot)
			storage.inventory_updated.emit(inventory_slot, inventory_item.texture, inventory_item.count)
			print("[ItemTransfer] Merged %s: hotbar %d + inventory %d = %d items in inventory %d" % [hotbar_item.item_name, hotbar_slot, inventory_slot, total_count, inventory_slot])
		else:
			# Fill inventory slot to max, keep remainder in hotbar
			var remainder = total_count - inventory_item.max_stack
			inventory_item.count = inventory_item.max_stack
			hotbar_item.count = remainder
			storage.hotbar_updated.emit(hotbar_slot, hotbar_item.texture, hotbar_item.count)
			storage.inventory_updated.emit(inventory_slot, inventory_item.texture, inventory_item.count)
			print("[ItemTransfer] Stacked %s: hotbar %d has %d, inventory %d is full (%d)" % [hotbar_item.item_name, hotbar_slot, remainder, inventory_slot, inventory_item.max_stack])
		return true

	# Different items or inventory slot is empty - normal swap
	storage.inventory_items[inventory_slot] = hotbar_item
	storage.hotbar_items[hotbar_slot] = inventory_item

	# Emit signals
	if inventory_item != null:
		storage.hotbar_updated.emit(hotbar_slot, inventory_item.texture, inventory_item.count)
	else:
		storage.hotbar_cleared.emit(hotbar_slot)

	storage.inventory_updated.emit(inventory_slot, hotbar_item.texture, hotbar_item.count)

	print("[ItemTransfer] Moved item from hotbar %d to inventory %d" % [hotbar_slot, inventory_slot])
	return true

func move_item_inventory_to_hotbar(inventory_slot: int, hotbar_slot: int) -> bool:
	"""Move item from inventory to hotbar. If items are the same type, stack them."""
	if inventory_slot < 0 or inventory_slot >= storage.inventory_items.size():
		return false
	if hotbar_slot < 0 or hotbar_slot >= storage.hotbar_items.size():
		return false

	var inventory_item = storage.inventory_items[inventory_slot]
	if inventory_item == null:
		return false

	var hotbar_item = storage.hotbar_items[hotbar_slot]

	# Check if both slots have items and are the same type
	if hotbar_item != null and inventory_item.item_name == hotbar_item.item_name:
		# Same item type - try to stack them
		var total_count = inventory_item.count + hotbar_item.count

		if total_count <= hotbar_item.max_stack:
			# Can merge all into hotbar slot
			hotbar_item.count = total_count
			storage.inventory_items[inventory_slot] = null
			storage.inventory_cleared.emit(inventory_slot)
			storage.hotbar_updated.emit(hotbar_slot, hotbar_item.texture, hotbar_item.count)
			print("[ItemTransfer] Merged %s: inventory %d + hotbar %d = %d items in hotbar %d" % [inventory_item.item_name, inventory_slot, hotbar_slot, total_count, hotbar_slot])
		else:
			# Fill hotbar slot to max, keep remainder in inventory
			var remainder = total_count - hotbar_item.max_stack
			hotbar_item.count = hotbar_item.max_stack
			inventory_item.count = remainder
			storage.inventory_updated.emit(inventory_slot, inventory_item.texture, inventory_item.count)
			storage.hotbar_updated.emit(hotbar_slot, hotbar_item.texture, hotbar_item.count)
			print("[ItemTransfer] Stacked %s: inventory %d has %d, hotbar %d is full (%d)" % [inventory_item.item_name, inventory_slot, remainder, hotbar_slot, hotbar_item.max_stack])
		return true

	# Different items or hotbar slot is empty - normal swap
	storage.hotbar_items[hotbar_slot] = inventory_item
	storage.inventory_items[inventory_slot] = hotbar_item

	# Emit signals
	if hotbar_item != null:
		storage.inventory_updated.emit(inventory_slot, hotbar_item.texture, hotbar_item.count)
	else:
		storage.inventory_cleared.emit(inventory_slot)

	storage.hotbar_updated.emit(hotbar_slot, inventory_item.texture, inventory_item.count)

	print("[ItemTransfer] Moved item from inventory %d to hotbar %d" % [inventory_slot, hotbar_slot])
	return true

# ==================== Inventory Swap ====================

func swap_inventory_slots(slot_a: int, slot_b: int) -> bool:
	"""Swap items between two inventory slots. If items are the same type, stack them."""
	if slot_a < 0 or slot_a >= storage.inventory_items.size():
		return false
	if slot_b < 0 or slot_b >= storage.inventory_items.size():
		return false

	# Don't swap with itself (fixes double-click bug)
	if slot_a == slot_b:
		return false

	var item_a = storage.inventory_items[slot_a]
	var item_b = storage.inventory_items[slot_b]

	# Check if both slots have items and are the same type
	if item_a != null and item_b != null and item_a.item_name == item_b.item_name:
		# Same item type - try to stack them
		var total_count = item_a.count + item_b.count

		if total_count <= item_b.max_stack:
			# Can merge all into slot B
			item_b.count = total_count
			storage.inventory_items[slot_a] = null
			storage.inventory_cleared.emit(slot_a)
			storage.inventory_updated.emit(slot_b, item_b.texture, item_b.count)
			print("[ItemTransfer] Merged %s: slot %d + slot %d = %d items in slot %d" % [item_a.item_name, slot_a, slot_b, total_count, slot_b])
		else:
			# Fill slot B to max, keep remainder in slot A
			var remainder = total_count - item_b.max_stack
			item_b.count = item_b.max_stack
			item_a.count = remainder
			storage.inventory_updated.emit(slot_a, item_a.texture, item_a.count)
			storage.inventory_updated.emit(slot_b, item_b.texture, item_b.count)
			print("[ItemTransfer] Stacked %s: slot %d has %d, slot %d is full (%d)" % [item_a.item_name, slot_a, remainder, slot_b, item_b.max_stack])
		return true

	# Different items or one is null - normal swap
	var temp = storage.inventory_items[slot_a]
	storage.inventory_items[slot_a] = storage.inventory_items[slot_b]
	storage.inventory_items[slot_b] = temp

	# Emit signals
	if storage.inventory_items[slot_a] != null:
		storage.inventory_updated.emit(slot_a, storage.inventory_items[slot_a].texture, storage.inventory_items[slot_a].count)
	else:
		storage.inventory_cleared.emit(slot_a)

	if storage.inventory_items[slot_b] != null:
		storage.inventory_updated.emit(slot_b, storage.inventory_items[slot_b].texture, storage.inventory_items[slot_b].count)
	else:
		storage.inventory_cleared.emit(slot_b)

	print("[ItemTransfer] Swapped inventory slots %d and %d" % [slot_a, slot_b])
	return true

# ==================== Hotbar Swap ====================

func swap_hotbar_slots(slot_a: int, slot_b: int) -> bool:
	"""Swap items between two hotbar slots. If items are the same type, stack them."""
	if slot_a < 0 or slot_a >= storage.hotbar_items.size():
		return false
	if slot_b < 0 or slot_b >= storage.hotbar_items.size():
		return false

	# Don't swap with itself (fixes double-click bug)
	if slot_a == slot_b:
		return false

	var item_a = storage.hotbar_items[slot_a]
	var item_b = storage.hotbar_items[slot_b]

	# Check if both slots have items and are the same type
	if item_a != null and item_b != null and item_a.item_name == item_b.item_name:
		# Same item type - try to stack them
		var total_count = item_a.count + item_b.count

		if total_count <= item_b.max_stack:
			# Can merge all into slot B
			item_b.count = total_count
			storage.hotbar_items[slot_a] = null
			storage.hotbar_cleared.emit(slot_a)
			storage.hotbar_updated.emit(slot_b, item_b.texture, item_b.count)
			print("[ItemTransfer] Merged %s: hotbar slot %d + slot %d = %d items in slot %d" % [item_a.item_name, slot_a, slot_b, total_count, slot_b])
		else:
			# Fill slot B to max, keep remainder in slot A
			var remainder = total_count - item_b.max_stack
			item_b.count = item_b.max_stack
			item_a.count = remainder
			storage.hotbar_updated.emit(slot_a, item_a.texture, item_a.count)
			storage.hotbar_updated.emit(slot_b, item_b.texture, item_b.count)
			print("[ItemTransfer] Stacked %s: hotbar slot %d has %d, slot %d is full (%d)" % [item_a.item_name, slot_a, remainder, slot_b, item_b.max_stack])
		return true

	# Different items or one is null - normal swap
	var temp = storage.hotbar_items[slot_a]
	storage.hotbar_items[slot_a] = storage.hotbar_items[slot_b]
	storage.hotbar_items[slot_b] = temp

	# Emit signals
	if storage.hotbar_items[slot_a] != null:
		storage.hotbar_updated.emit(slot_a, storage.hotbar_items[slot_a].texture, storage.hotbar_items[slot_a].count)
	else:
		storage.hotbar_cleared.emit(slot_a)

	if storage.hotbar_items[slot_b] != null:
		storage.hotbar_updated.emit(slot_b, storage.hotbar_items[slot_b].texture, storage.hotbar_items[slot_b].count)
	else:
		storage.hotbar_cleared.emit(slot_b)

	print("[ItemTransfer] Swapped hotbar slots %d and %d" % [slot_a, slot_b])
	return true
