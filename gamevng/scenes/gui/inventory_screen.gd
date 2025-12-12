extends Control
class_name InventoryScreen

signal inventory_slot_clicked(slot_index: int)
signal item_dropped(slot_index: int)

@export var columns: int = 5
@export var rows: int = 3
@export var slot_size: Vector2 = Vector2(40, 40)
@export var slot_spacing: int = 4

var total_slots: int = 15  # 3 rows x 5 columns
var slots: Array[InventorySlot] = []

@onready var slots_container: GridContainer = $Panel/MarginContainer/VBoxContainer/SlotsGrid
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/TopBar/CloseButton
@onready var coins_label: Label = $Panel/MarginContainer/VBoxContainer/TopBar/CoinsLabel
@onready var keys_label: Label = $Panel/MarginContainer/VBoxContainer/TopBar/KeysLabel

func _ready() -> void:
	# Hide by default
	visible = false

	# Setup grid container
	slots_container.columns = columns

	# Create slots
	create_slots()

	# Connect close button
	close_button.pressed.connect(_on_close_button_pressed)

	# Connect to inventory system signals
	if GameManager.inventory_system:
		GameManager.inventory_system.coin_changed.connect(_on_coins_changed)
		GameManager.inventory_system.key_changed.connect(_on_keys_changed)

	print("[InventoryScreen] Inventory screen ready with %d slots" % total_slots)

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

	# Create new slots
	for i in range(total_slots):
		var slot = InventorySlot.new()
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
	update_currency_display()
	print("[InventoryScreen] Inventory opened")

func hide_inventory() -> void:
	visible = false
	print("[InventoryScreen] Inventory closed")

func _on_close_button_pressed() -> void:
	hide_inventory()

func _on_slot_clicked(slot_index: int) -> void:
	print("[InventoryScreen] Slot %d clicked" % slot_index)
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

func update_currency_display() -> void:
	if GameManager.inventory_system:
		var coins = GameManager.inventory_system.get_gold()
		var keys = GameManager.inventory_system.get_keys()
		coins_label.text = "Coins: %d" % coins
		keys_label.text = "Keys: %d" % keys

func _on_coins_changed(new_amount: int) -> void:
	coins_label.text = "Coins: %d" % new_amount

func _on_keys_changed(new_amount: int) -> void:
	keys_label.text = "Keys: %d" % new_amount

# =========================
# InventorySlot class definition
# =========================
class InventorySlot extends Control:
	signal slot_clicked(slot_index: int)

	var slot_index: int
	var item_texture: Texture2D
	var item_count: int = 0

	@onready var background: ColorRect
	@onready var item_icon: TextureRect
	@onready var count_label: Label

	func setup(index: int, size: Vector2) -> void:
		slot_index = index
		custom_minimum_size = size

		# Create slot background
		background = ColorRect.new()
		background.color = Color(0.15, 0.15, 0.15, 0.95)
		background.anchors_preset = Control.PRESET_FULL_RECT
		add_child(background)

		# Create borders (same style as hotbar)
		var border_top = ColorRect.new()
		border_top.color = Color(0.6, 0.6, 0.6, 1.0)
		border_top.anchors_preset = Control.PRESET_TOP_WIDE
		border_top.anchor_bottom = 0.0
		border_top.offset_bottom = 2
		add_child(border_top)

		var border_bottom = ColorRect.new()
		border_bottom.color = Color(0.3, 0.3, 0.3, 1.0)
		border_bottom.anchors_preset = Control.PRESET_BOTTOM_WIDE
		border_bottom.anchor_top = 1.0
		border_bottom.offset_top = -2
		add_child(border_bottom)

		var border_left = ColorRect.new()
		border_left.color = Color(0.5, 0.5, 0.5, 1.0)
		border_left.anchors_preset = Control.PRESET_LEFT_WIDE
		border_left.anchor_right = 0.0
		border_left.offset_right = 2
		add_child(border_left)

		var border_right = ColorRect.new()
		border_right.color = Color(0.4, 0.4, 0.4, 1.0)
		border_right.anchors_preset = Control.PRESET_RIGHT_WIDE
		border_right.anchor_left = 1.0
		border_right.offset_left = -2
		add_child(border_right)

		# Create item icon
		item_icon = TextureRect.new()
		item_icon.anchors_preset = Control.PRESET_FULL_RECT
		item_icon.anchor_left = 0.15
		item_icon.anchor_top = 0.15
		item_icon.anchor_right = 0.85
		item_icon.anchor_bottom = 0.85
		item_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_icon.visible = false
		add_child(item_icon)

		# Create count label
		count_label = Label.new()
		count_label.anchors_preset = Control.PRESET_BOTTOM_RIGHT
		count_label.anchor_left = 0.5
		count_label.anchor_top = 0.5
		count_label.anchor_right = 1.0
		count_label.anchor_bottom = 1.0
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		count_label.add_theme_font_size_override("font_size", 10)
		count_label.add_theme_color_override("font_color", Color.WHITE)
		count_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		count_label.add_theme_constant_override("shadow_offset_x", 1)
		count_label.add_theme_constant_override("shadow_offset_y", 1)
		count_label.visible = false
		add_child(count_label)

		# Setup hover and click effects
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)

		# Make clickable
		gui_input.connect(_on_gui_input)

	func set_item(texture: Texture2D, count: int = 1) -> void:
		item_texture = texture
		item_count = count

		if not item_icon:
			return

		item_icon.texture = texture
		item_icon.visible = texture != null

		if texture:
			item_icon.z_index = 10

		if count > 1:
			count_label.text = str(count)
			count_label.visible = true
		else:
			count_label.visible = false

	func clear_item() -> void:
		item_texture = null
		item_count = 0
		item_icon.texture = null
		item_icon.visible = false
		count_label.visible = false

	func _on_mouse_entered() -> void:
		background.color = Color(0.25, 0.25, 0.35, 0.95)

	func _on_mouse_exited() -> void:
		background.color = Color(0.15, 0.15, 0.15, 0.95)

	func _on_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(slot_index)
