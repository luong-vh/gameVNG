extends Node
class_name InventorySystem

signal coin_changed(new_amount: int)
signal item_collected(item_type: String, amount: int)
signal key_changed(new_amount: int) # Thêm signal này để cập nhật số lượng key
signal hotbar_updated(slot_index: int, texture: Texture2D, count: int)
signal hotbar_cleared(slot_index: int)

var coins: int = 0
var keys: int = 0

# Hotbar system
var hotbar_items: Array[ItemData] = []
var hotbar_size: int = 5

class ItemData:
	var item_name: String
	var texture: Texture2D
	var count: int
	var max_stack: int
	
	func _init(name: String = "", tex: Texture2D = null, amount: int = 1, stack: int = 99):
		item_name = name
		texture = tex
		count = amount
		max_stack = stack

func _ready() -> void:
	# Initialize hotbar
	initialize_hotbar()
	pass
	
func add_coin(amount: int) -> void:
	coins += amount
	coin_changed.emit(coins)
	item_collected.emit("coin", amount)
	print("Collected ", amount, " coins. Total: ", coins)
	
func add_key(_amount: int = 1) -> void:
	# IMPLEMENT: Thực hiện việc thêm chìa khóa
	keys += _amount
	key_changed.emit(keys) # Phát tín hiệu thay đổi key
	item_collected.emit("key", _amount) # Phát tín hiệu vật phẩm được thu thập
	print("Collected ", _amount, " keys. Total: ", keys)
	
func use_key() -> bool:
	# IMPLEMENT: Thực hiện việc dùng chìa khóa
	if keys > 0:
		keys -= 1
		key_changed.emit(keys) # Phát tín hiệu thay đổi key
		print("Used 1 key. Remaining: ", keys)
		return true
	
	print("ERROR: Tried to use key but inventory is empty.")
	return false # Trả về false nếu không có chìa khóa để dùng

func has_key() -> bool:
	return keys > 0	

func get_gold() -> int:
	return coins

func get_keys() -> int:
	return keys


# ==================== Save/Load System ====================

func save_state() -> Dictionary:
	var hotbar_save_data = []
	for item in hotbar_items:
		if item != null:
			hotbar_save_data.append({
				"name": item.item_name,
				"count": item.count,
				"max_stack": item.max_stack,
				"texture_path": item.texture.resource_path if item.texture else ""
			})
		else:
			hotbar_save_data.append(null)
	
	return {
		"coins": coins,
		"keys": keys,
		"hotbar_items": hotbar_save_data
	}

func load_state(state: Dictionary) -> void:
	if state.has("coins"):
		coins = state.coins
		coin_changed.emit(coins)

	if state.has("keys"):
		keys = state.keys
		key_changed.emit(keys)
	
	# Load hotbar items
	if state.has("hotbar_items"):
		var hotbar_data = state.hotbar_items
		hotbar_items.clear()
		
		for i in range(hotbar_size):
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
				hotbar_items.append(item)
				hotbar_updated.emit(i, item.texture, item.count)
			else:
				hotbar_items.append(null)

	print("[InventorySystem] Loaded state - Coins: %d, Keys: %d" % [coins, keys])

func reset_inventory() -> void:
	coins = 0
	keys = 0
	coin_changed.emit(coins)
	key_changed.emit(keys)
	clear_hotbar()
	print("[InventorySystem] Reset to zero")

# ==================== Hotbar System ====================

func initialize_hotbar() -> void:
	hotbar_items.clear()
	for i in range(hotbar_size):
		hotbar_items.append(null)

func add_item_to_hotbar(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	# Try to stack with existing item first
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
	
	print("[InventorySystem] Hotbar is full!")
	return false

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
	
	print("[InventorySystem] Used item: %s" % item.item_name)
	return true

func get_hotbar_item(slot_index: int) -> ItemData:
	if slot_index >= 0 and slot_index < hotbar_items.size():
		return hotbar_items[slot_index]
	return null

func clear_hotbar() -> void:
	for i in range(hotbar_items.size()):
		hotbar_items[i] = null
		hotbar_cleared.emit(i)
