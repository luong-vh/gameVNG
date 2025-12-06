extends Node
class_name InventorySystem

signal coin_changed(new_amount: int)
signal item_collected(item_type: String, amount: int)
signal key_changed(new_amount: int) # Thêm signal này để cập nhật số lượng key

var coins: int = 0
var keys: int = 0

func _ready() -> void:
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
	return {
		"coins": coins,
		"keys": keys
	}

func load_state(state: Dictionary) -> void:
	if state.has("coins"):
		coins = state.coins
		coin_changed.emit(coins)

	if state.has("keys"):
		keys = state.keys
		key_changed.emit(keys)

	print("[InventorySystem] Loaded state - Coins: %d, Keys: %d" % [coins, keys])

func reset_inventory() -> void:
	coins = 0
	keys = 0
	coin_changed.emit(coins)
	key_changed.emit(keys)
	print("[InventorySystem] Reset to zero")
