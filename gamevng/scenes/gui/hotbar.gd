extends Control
class_name Hotbar

signal slot_selected(slot_index: int)
signal item_used(slot_index: int)

@export var slot_count: int = 5
@export var slot_size: Vector2 = Vector2(32, 32)
@export var slot_spacing: int = 4

var slots: Array[HotbarSlot] = []
var selected_slot: int = 0

@onready var slots_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	create_slots()
	update_selected_slot()
	print("[Hotbar] Hotbar ready with %d slots" % slot_count)
	
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
	
	# Create new slots
	for i in range(slot_count):
		var slot = HotbarSlot.new()
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
	# Remove click functionality - now handled by number keys only
	pass

# =========================
# HotbarSlot class definition
# =========================
class HotbarSlot extends Control:
	signal slot_clicked(slot_index: int)
	
	var slot_index: int
	var item_texture: Texture2D
	var item_count: int = 0
	var is_selected: bool = false
	
	@onready var background: ColorRect
	@onready var item_icon: TextureRect
	@onready var count_label: Label
	# Remove selection_border since we don't need it anymore
	
	func setup(index: int, size: Vector2) -> void:
		slot_index = index
		custom_minimum_size = size
		
		# Create individual slot background with border
		background = ColorRect.new()
		background.color = Color(0.15, 0.15, 0.15, 0.9)  # Darker background
		background.anchors_preset = Control.PRESET_FULL_RECT
		add_child(background)
		
		# Create border for each slot
		var border = ColorRect.new()
		border.color = Color.TRANSPARENT
		border.anchors_preset = Control.PRESET_FULL_RECT
		# Create border effect using multiple ColorRects
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
		
		# Create item icon with proper margins
		item_icon = TextureRect.new()
		item_icon.anchors_preset = Control.PRESET_FULL_RECT
		item_icon.anchor_left = 0.15
		item_icon.anchor_top = 0.15  
		item_icon.anchor_right = 0.85
		item_icon.anchor_bottom = 0.85
		item_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(item_icon)
		
		# Create count label in bottom-right corner
		count_label = Label.new()
		count_label.anchors_preset = Control.PRESET_BOTTOM_RIGHT
		count_label.anchor_left = 0.6
		count_label.anchor_top = 0.6
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
		
		# Setup hover effects only (no click)
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		
		print("[HotbarSlot] Slot %d setup complete" % index)
	
	func set_item(texture: Texture2D, count: int = 1) -> void:
		item_texture = texture
		item_count = count
		
		print("[HotbarSlot] Setting item in slot %d:" % slot_index)
		print("  - Texture: %s" % texture)
		print("  - Count: %d" % count)
		print("  - Icon node: %s" % item_icon)
		
		if not item_icon:
			print("[HotbarSlot] ERROR: item_icon is null!")
			return
			
		item_icon.texture = texture
		item_icon.visible = texture != null
		
		if texture:
			print("  - Icon set to visible, texture size: %s" % texture.get_size())
			# Force icon to be above other elements
			item_icon.z_index = 10
		else:
			print("  - No texture provided, icon hidden")
		
		if count > 1:
			count_label.text = str(count)
			count_label.visible = true
			print("  - Count label shown: %s" % count)
		else:
			count_label.visible = false
			print("  - Count label hidden")
	
	func clear_item() -> void:
		item_texture = null
		item_count = 0
		item_icon.texture = null
		item_icon.visible = false
		count_label.visible = false
	
	func set_selected(selected: bool) -> void:
		is_selected = selected
		# Remove selection border functionality since we don't use selection anymore
	
	func _on_mouse_entered() -> void:
		# Subtle hover effect
		background.color = Color(0.25, 0.25, 0.35, 0.9)  # Slightly blue tint on hover
	
	func _on_mouse_exited() -> void:
		background.color = Color(0.15, 0.15, 0.15, 0.9)  # Back to normal
