extends PanelContainer
class_name ShopItemSlot

signal item_buy_requested(slot_index: int)

var slot_index: int = -1
var item_name: String = ""
var item_price: int = 0

func _ready() -> void:
	var buy_button = get_node_or_null("HBoxContainer/BuyButton")
	if buy_button:
		buy_button.pressed.connect(_on_buy_button_pressed)

func setup_item(index: int, _item_name: String, texture: Texture2D, price: int) -> void:
	slot_index = index
	item_name = _item_name
	item_price = price

	# Get nodes directly instead of using @onready
	var item_icon = get_node_or_null("HBoxContainer/ItemIcon")
	var item_name_label = get_node_or_null("HBoxContainer/VBoxContainer/ItemNameLabel")
	var price_label = get_node_or_null("HBoxContainer/VBoxContainer/PriceLabel")

	# Set icon
	if item_icon:
		item_icon.texture = texture

	# Set name
	if item_name_label:
		item_name_label.text = _item_name.capitalize()

	# Set price
	if price_label:
		price_label.text = "%d coins" % price

func _on_buy_button_pressed() -> void:
	item_buy_requested.emit(slot_index)
