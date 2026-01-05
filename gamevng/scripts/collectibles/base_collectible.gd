extends Area2D
class_name BaseCollectible

## Base class for all collectible items with save/load support

signal interacted
signal interaction_available
signal interaction_unavailable

@export_group("Save Settings")
@export var object_id: String = ""
@export var save_enabled: bool = true

@export_group("Collectible Settings")
@export var interact_input_action: String = ""
@export var is_attractable: bool = true
@export var show_when_collected: bool = false  # Có hiển thị mờ khi đã collect không (dùng cho coins)
@export var collected_alpha: float = 0.4:  # Độ mờ khi đã collect (0.0 = invisible, 1.0 = opaque)
	set(value):
		collected_alpha = clamp(value, 0.0, 1.0)

var collected: bool = false  # true = đã thu thập rồi (lần đầu)
var initial_state: Dictionary = {}
var scene_default_state: Dictionary = {}
var _is_restoring_state: bool = false  # Flag để prevent auto-trigger khi restore

func _ready() -> void:
	if object_id.is_empty():
		# Nếu tên là auto-generated (@Area2D@xxx), dùng position để tạo unique ID
		var node_name = name
		if node_name.begins_with("@"):
			# Sử dụng position (làm tròn) để tạo ID unique và stable
			var pos_x = int(global_position.x)
			var pos_y = int(global_position.y)
			object_id = "%s_pos%d_%d" % [get_parent().name if get_parent() else "root", pos_x, pos_y]
		else:
			# Tên thông thường, dùng parent + name
			object_id = "%s_%s" % [get_parent().name if get_parent() else "root", node_name]

	_save_initial_state()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interact_input_action.is_empty():
		set_process_unhandled_input(false)
	else:
		set_process_unhandled_input(false)

	add_to_group("collectibles")
	interaction_available.connect(_on_collect)


func _unhandled_input(event):
	if interact_input_action and event.is_action_pressed(interact_input_action):
		interacted.emit()
		var viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _on_body_entered(_body: Node2D) -> void:
	# Không trigger nếu đang restore state
	if _is_restoring_state:
		return

	# Cho phép tương tác cả khi đã collected (để ăn lại và biến mất)
	if not interact_input_action.is_empty():
		set_process_unhandled_input(true)

	interaction_available.emit.call_deferred()

func _on_body_exited(_body: Node2D) -> void:
	set_process_unhandled_input(false)
	interaction_unavailable.emit.call_deferred()

func _on_collect() -> void:
	# Nếu KHÔNG phải coins (show_when_collected = false), thì set collected và ẩn đi
	if not show_when_collected:
		if collected:
			return  # Đã collect rồi, không làm gì
		collected = true
		visible = false
		monitoring = false

func _on_interacted_by_player() -> void:
	pass

func _save_initial_state() -> void:
	var state = get_state()
	initial_state = state
	scene_default_state = state.duplicate()

func get_state() -> Dictionary:
	return {
		"pos_x": position.x,
		"pos_y": position.y,
		"visible": visible,
		"collected": collected,
		"monitoring": monitoring
	}

func set_state(state: Dictionary) -> void:
	# Set flag để prevent auto-trigger _on_collect khi restore
	_is_restoring_state = true

	if state.has("pos_x") and state.has("pos_y"):
		position = Vector2(state.pos_x, state.pos_y)

	# Flag để track xem có cần override visible/monitoring không
	var override_visibility = false

	if state.has("collected"):
		collected = state.collected

		# Chỉ áp dụng logic "hiển thị mờ" nếu show_when_collected = true (dùng cho coins)
		if show_when_collected and collected:
			override_visibility = true
			modulate.a = collected_alpha
			visible = true  # BẮT BUỘC hiển thị mờ
			monitoring = true  # BẮT BUỘC cho phép tương tác để ăn lại
		else:
			# Behavior mặc định cho các collectibles khác
			modulate.a = 1.0

	# Chỉ áp dụng visible/monitoring từ state nếu KHÔNG override
	if not override_visibility:
		if state.has("visible"):
			visible = state.visible

		if state.has("monitoring"):
			monitoring = state.monitoring

	# Reset flag sau khi hoàn tất restore (dùng call_deferred để đảm bảo xong hết collision)
	_reset_restoring_flag.call_deferred()

func _reset_restoring_flag() -> void:
	_is_restoring_state = false

func reset_to_initial() -> void:
	if not initial_state.is_empty():
		set_state(initial_state)

func reset_to_scene_default() -> void:
	if not scene_default_state.is_empty():
		set_state(scene_default_state)

func confirm_current_state() -> void:
	initial_state = get_state()
