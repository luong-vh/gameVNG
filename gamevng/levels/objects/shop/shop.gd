extends CanvasLayer
class_name Shop

signal shop_opened
signal shop_closed
signal item_purchased(item_name: String, price: int)

# Shop state
var is_shop_open: bool = false
var player_in_range: bool = false

# Shop items data [item_name, texture_path, price, item_type]
var shop_items: Array = [
	{"name": "health_potion", "texture": "res://assets/items/potions/pt1.png", "price": 10},
	{"name": "health_potion", "texture": "res://assets/items/potions/pt2.png", "price": 15},
	{"name": "health_potion", "texture": "res://assets/items/potions/pt3.png", "price": 20},
	{"name": "health_potion", "texture": "res://assets/items/potions/pt4.png", "price": 25},
	{"name": "shield", "texture": "res://assets/items/shield.png", "price": 30},
	{"name": "speed_boost", "texture": "res://assets/items/speed_up.png", "price": 35}
]

# UI References
@onready var shop_panel = $ShopPanel
@onready var items_container = $ShopPanel/VBoxContainer/ScrollContainer/ItemsContainer
@onready var coin_label = $ShopPanel/VBoxContainer/CoinDisplay/CoinLabel
@onready var close_button = $ShopPanel/VBoxContainer/CloseButton

# Preload item slot scene
var item_slot_scene = preload("res://levels/objects/shop/shop_item_slot.tscn")

func _ready() -> void:
	# Set process mode to always run, even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide shop initially
	visible = false
	is_shop_open = false

	# Setup close button
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

	# Populate shop items
	_populate_shop_items()

func _process(_delta: float) -> void:
	# Handle F key to open/close shop
	if Input.is_action_just_pressed("interact"): # F key
		if is_shop_open:
			# Always allow closing shop with F key
			close_shop()
		elif player_in_range:
			# Only allow opening if player is in range
			open_shop()

func toggle_shop() -> void:
	if is_shop_open:
		close_shop()
	else:
		open_shop()

func open_shop() -> void:
	is_shop_open = true
	visible = true
	get_tree().paused = true
	_update_coin_display()
	shop_opened.emit()

func close_shop() -> void:
	is_shop_open = false
	visible = false
	get_tree().paused = false
	shop_closed.emit()

func _populate_shop_items() -> void:
	if not items_container:
		return

	# Clear existing items
	for child in items_container.get_children():
		child.queue_free()

	# Create item slots
	for i in range(shop_items.size()):
		var item_data = shop_items[i]

		# Load texture
		var texture = load(item_data.texture)

		var item_slot = item_slot_scene.instantiate()
		items_container.add_child(item_slot)

		# Setup item slot
		item_slot.setup_item(i, item_data.name, texture, item_data.price)

		# Connect purchase signal
		item_slot.item_buy_requested.connect(_on_item_purchase_requested)

func _on_item_purchase_requested(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= shop_items.size():
		return

	var item = shop_items[slot_index]
	purchase_item(item.name, item.price, load(item.texture))

func purchase_item(item_name: String, price: int, texture: Texture2D) -> bool:
	# Check if player has enough coins
	if not GameManager.inventory_system:
		return false

	var current_coins = GameManager.inventory_system.get_gold()
	if current_coins < price:
		# Play error sound if available
		if AudioManager.has_method("play_sound"):
			AudioManager.play_sound("coin")
		return false

	# Deduct coins
	GameManager.inventory_system.coins -= price

	# Add item to inventory
	var success = GameManager.inventory_system.add_item_to_hotbar(item_name, texture, 1)

	if success:
		AudioManager.play_sound("coin") # Play success sound
		_update_coin_display()
		item_purchased.emit(item_name, price)
		return true
	else:
		# Refund if adding to inventory failed
		GameManager.inventory_system.coins += price
		return false

func _update_coin_display() -> void:
	if coin_label and GameManager.inventory_system:
		coin_label.text = str(GameManager.inventory_system.get_gold())

func _on_close_button_pressed() -> void:
	close_shop()

# Called when player enters shop area
func _on_player_entered_shop_area(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

# Called when player exits shop area
func _on_player_exited_shop_area(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		if is_shop_open:
			close_shop()
