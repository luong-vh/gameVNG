extends Node
class_name InventorySystem

# Public signals
signal coin_changed(new_amount: int)
signal item_collected(item_type: String, amount: int)
signal key_changed(new_amount: int)
signal hotbar_updated(slot_index: int, texture: Texture2D, count: int)
signal hotbar_cleared(slot_index: int)
signal inventory_updated(slot_index: int, texture: Texture2D, count: int)
signal inventory_cleared(slot_index: int)

# Currency
var coins: int = 0:
	set (value):
		coins = value
		coin_changed.emit(coins)
		GUIManager.update_coin(coins)
		
var keys: int = 0:
	set(value):
		keys = value
		key_changed.emit(keys)
		GUIManager.update_key(value > 0)

# Modules
var storage: ItemStorage
var transfer: ItemTransfer
var persistence: InventoryPersistence

# Drag & Drop shared state
var dragging_from_hotbar: bool = false
var dragging_from_inventory: bool = false
var dragging_slot_index: int = -1

# Configuration (exposed for compatibility)
var hotbar_size: int = 5:
	get: return storage.hotbar_size if storage else 5
var inventory_size: int = 15:
	get: return storage.inventory_size if storage else 15

# Direct access to arrays (for compatibility)
var hotbar_items: Array[ItemData]:
	get: return storage.hotbar_items if storage else []
var inventory_items: Array[ItemData]:
	get: return storage.inventory_items if storage else []

func _ready() -> void:
	# Initialize modules
	storage = ItemStorage.new()
	transfer = ItemTransfer.new(storage)
	persistence = InventoryPersistence.new(storage)

	# Forward signals from storage to public signals
	storage.hotbar_updated.connect(func(idx, tex, cnt): hotbar_updated.emit(idx, tex, cnt))
	storage.hotbar_cleared.connect(func(idx): hotbar_cleared.emit(idx))
	storage.inventory_updated.connect(func(idx, tex, cnt): inventory_updated.emit(idx, tex, cnt))
	storage.inventory_cleared.connect(func(idx): inventory_cleared.emit(idx))

	# Initialize storage
	storage.initialize()
	print("[InventorySystem] Initialized with modular architecture")

# ==================== Currency Management ====================

func add_coin(amount: int) -> void:
	coins += amount
	item_collected.emit("coin", amount)
	print("Collected ", amount, " coins. Total: ", coins)

func add_key(_amount: int = 1) -> void:
	keys += _amount
	key_changed.emit(keys)
	item_collected.emit("key", _amount)
	print("Collected ", _amount, " keys. Total: ", keys)

func use_key() -> bool:
	if keys > 0:
		keys -= 1
		key_changed.emit(keys)
		print("Used 1 key. Remaining: ", keys)
		return true

	print("ERROR: Tried to use key but inventory is empty.")
	return false

func has_key() -> bool:
	return keys > 0

func get_gold() -> int:
	return coins

func get_keys() -> int:
	return keys

# ==================== Save/Load System ====================

func save_state() -> Dictionary:
	return persistence.save_state(coins, keys)

func load_state(state: Dictionary) -> void:
	var result = persistence.load_state(state)
	coins = result.coins
	keys = result.keys
	coin_changed.emit(coins)
	key_changed.emit(keys)

func reset_inventory() -> void:
	coins = 0
	keys = 0
	coin_changed.emit(coins)
	key_changed.emit(keys)
	storage.clear_hotbar()
	storage.clear_inventory()
	print("[InventorySystem] Reset to zero")

# ==================== Hotbar API (Delegated to Storage) ====================

func initialize_hotbar() -> void:
	storage.initialize_hotbar()

func add_item_to_hotbar(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	var success = storage.add_item_to_hotbar(item_name, texture, count)
	if not success:
		# Hotbar is full, try inventory
		print("[InventorySystem] Hotbar is full! Moving to inventory...")
		return add_item_to_inventory(item_name, texture, count)
	return success

func use_item_from_hotbar(slot_index: int) -> bool:
	return storage.use_item_from_hotbar(slot_index)

func get_hotbar_item(slot_index: int) -> ItemData:
	return storage.get_hotbar_item(slot_index)

func set_hotbar_slot(slot_index: int, item_name: String, texture: Texture2D, count: int = 1) -> bool:
	return storage.set_hotbar_slot(slot_index, item_name, texture, count)

func clear_hotbar_slot(slot_index: int) -> void:
	storage.clear_hotbar_slot(slot_index)

func clear_hotbar() -> void:
	storage.clear_hotbar()

# ==================== Inventory API (Delegated to Storage) ====================

func initialize_inventory() -> void:
	storage.initialize_inventory()

func add_item_to_inventory(item_name: String, texture: Texture2D, count: int = 1) -> bool:
	return storage.add_item_to_inventory(item_name, texture, count)

func get_inventory_item(slot_index: int) -> ItemData:
	return storage.get_inventory_item(slot_index)

func set_inventory_slot(slot_index: int, item_name: String, texture: Texture2D, count: int = 1) -> bool:
	return storage.set_inventory_slot(slot_index, item_name, texture, count)

func clear_inventory_slot(slot_index: int) -> void:
	storage.clear_inventory_slot(slot_index)

func clear_inventory() -> void:
	storage.clear_inventory()

func use_item_from_inventory(slot_index: int) -> bool:
	return storage.use_item_from_inventory(slot_index)

# ==================== Transfer API (Delegated to Transfer) ====================

func move_item_hotbar_to_inventory(hotbar_slot: int, inventory_slot: int) -> bool:
	return transfer.move_item_hotbar_to_inventory(hotbar_slot, inventory_slot)

func move_item_inventory_to_hotbar(inventory_slot: int, hotbar_slot: int) -> bool:
	return transfer.move_item_inventory_to_hotbar(inventory_slot, hotbar_slot)

func swap_inventory_slots(slot_a: int, slot_b: int) -> bool:
	return transfer.swap_inventory_slots(slot_a, slot_b)

func swap_hotbar_slots(slot_a: int, slot_b: int) -> bool:
	return transfer.swap_hotbar_slots(slot_a, slot_b)
