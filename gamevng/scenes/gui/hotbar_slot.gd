extends Control
class_name HotbarSlot

signal slot_clicked(slot_index: int)

var slot_index: int = 0
var item_texture: Texture2D
var item_count: int = 0
var is_selected: bool = false

@onready var background: TextureRect = $Background
@onready var item_icon: TextureRect = $ItemIcon
@onready var count_label: Label = $CountLabel

func _ready() -> void:
	# Setup mouse detection
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

	# Hide item icon and count by default
	item_icon.visible = false
	count_label.visible = false

func setup(index: int, size: Vector2) -> void:
	slot_index = index
	custom_minimum_size = size

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

func set_selected(selected: bool) -> void:
	is_selected = selected

func _on_mouse_entered() -> void:
	# Lighten on hover
	background.modulate = Color(1.3, 1.3, 1.3, 1.0)

func _on_mouse_exited() -> void:
	# Reset to normal
	background.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(slot_index)

func set_dragging(is_dragging: bool) -> void:
	"""Visual feedback for dragging state"""
	if is_dragging:
		# Blue tint when dragging
		background.modulate = Color(0.8, 0.8, 1.5, 1.0)
	else:
		# Normal color
		background.modulate = Color(1.0, 1.0, 1.0, 1.0)
