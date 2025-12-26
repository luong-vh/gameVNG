extends RefCounted
class_name InventoryPersistence

var storage: ItemStorage

func _init(item_storage: ItemStorage):
	storage = item_storage

# ==================== Save System ====================

func save_state(coins: int, keys: int) -> Dictionary:
	var hotbar_save_data = []
	for item in storage.hotbar_items:
		if item != null:
			hotbar_save_data.append({
				"name": item.item_name,
				"count": item.count,
				"max_stack": item.max_stack,
				"texture_path": item.texture.resource_path if item.texture else ""
			})
		else:
			hotbar_save_data.append(null)

	var inventory_save_data = []
	for item in storage.inventory_items:
		if item != null:
			inventory_save_data.append({
				"name": item.item_name,
				"count": item.count,
				"max_stack": item.max_stack,
				"texture_path": item.texture.resource_path if item.texture else ""
			})
		else:
			inventory_save_data.append(null)

	return {
		"coins": coins,
		"keys": keys,
		"hotbar_items": hotbar_save_data,
		"inventory_items": inventory_save_data
	}

# ==================== Load System ====================

func load_state(state: Dictionary) -> Dictionary:
	"""Load inventory state and return coins/keys values"""
	var result = {"coins": 0, "keys": 0}

	if state.has("coins"):
		result.coins = state.coins

	if state.has("keys"):
		result.keys = state.keys

	# Load hotbar items
	if state.has("hotbar_items"):
		var hotbar_data = state.hotbar_items
		storage.hotbar_items.clear()

		for i in range(storage.hotbar_size):
			if i < hotbar_data.size() and hotbar_data[i] != null:
				var item_data = hotbar_data[i]
				var texture = null
				if item_data.has("texture_path") and not item_data.texture_path.is_empty():
					texture = load(item_data.texture_path)

				var item = ItemData.new(
					item_data.get("name", ""),
					texture,
					item_data.get("count", 1),
					item_data.get("max_stack", 99)
				)
				storage.hotbar_items.append(item)
				storage.hotbar_updated.emit(i, item.texture, item.count)
			else:
				storage.hotbar_items.append(null)
				storage.hotbar_cleared.emit(i)  # Clear GUI when slot is empty
	else:
		# No hotbar data in checkpoint - clear everything
		storage.clear_hotbar()

	# Load inventory items
	if state.has("inventory_items"):
		var inventory_data = state.inventory_items
		storage.inventory_items.clear()

		for i in range(storage.inventory_size):
			if i < inventory_data.size() and inventory_data[i] != null:
				var item_data = inventory_data[i]
				var texture = null
				if item_data.has("texture_path") and not item_data.texture_path.is_empty():
					texture = load(item_data.texture_path)

				var item = ItemData.new(
					item_data.get("name", ""),
					texture,
					item_data.get("count", 1),
					item_data.get("max_stack", 99)
				)
				storage.inventory_items.append(item)
				storage.inventory_updated.emit(i, item.texture, item.count)
			else:
				storage.inventory_items.append(null)
				storage.inventory_cleared.emit(i)  # Clear GUI when slot is empty
	else:
		# No inventory data in checkpoint - clear everything
		storage.clear_inventory()

	return result
