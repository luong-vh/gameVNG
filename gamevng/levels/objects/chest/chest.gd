extends BaseCollectible

# This collectible should not be attracted by magnets

# Số coin mà mày nhận được khi mở rương
@export var coin_reward: int = 5 
# Cờ (flag) để kiểm tra xem rương đã mở chưa
var is_opened: bool = false 

# Lấy node AnimatedSprite2D làm con
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin_scene = preload("res://scenes/collectibles/coin.tscn")

func _ready():
	super._ready() # Call the base class's _ready
	is_attractable = false
	interact_input_action = "interact"  # Require pressing F to open chest
	# Disconnect the default interaction_available from _on_collect
	interaction_available.disconnect(_on_collect)
	# Connect the interacted signal to the specific interaction method for chests
	interacted.connect(_on_interacted_by_player)
	# Chạy animation "close" (đóng) khi rương khởi tạo
	animated_sprite.play("close")

func _on_interacted_by_player():
	attempt_open_chest()

func attempt_open_chest():
	# Nếu rương đã mở rồi thì không làm gì nữa, thoát luôn
	if is_opened:
		return
	
	# Kiểm tra xem người chơi có chìa khóa không (Giả định GameManager có hàm has_key)
	if GameManager.inventory_system.has_key():
		open_chest()

func open_chest():
	# Kiểm tra lại lần nữa (dù đã kiểm tra ở hàm trên)
	if is_opened:
		return

	# Đặt cờ là đã mở
	is_opened = true

	# Sử dụng chìa khóa trong hệ thống tồn kho (Giả định GameManager có hàm use_key)
	GameManager.inventory_system.use_key()

	# Chạy animation "open" (mở)
	animated_sprite.play("open")

	# Đợi cho animation "open" chạy xong (chỉ dùng trong Godot 4 trở lên)
	await animated_sprite.animation_finished

	# Spawn coins
	for i in range(coin_reward):
		var coin_instance = coin_scene.instantiate()
		get_parent().add_child(coin_instance)
		coin_instance.global_position = global_position

		var tween = create_tween()
		var random_x_offset = randf_range(-50, 50)
		var random_y_offset = randf_range(-100, -50)
		var target_position = global_position + Vector2(random_x_offset, random_y_offset)

		tween.tween_property(coin_instance, "global_position", target_position, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(coin_instance, "global_position", target_position + Vector2(0, 50), 0.5)\
			.set_delay(0.2)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_QUAD)

	# In ra thông báo
	print("Chest opened! Spawning ", coin_reward, " coins!")
	GameManager.stage_clear()


# ==================== Save/Load System ====================

func get_state() -> Dictionary:
	var state = super.get_state()
	state["is_opened"] = is_opened
	return state

func set_state(state: Dictionary) -> void:
	super.set_state(state)

	if state.has("is_opened"):
		is_opened = state.is_opened

		# If chest was opened, show it in opened state
		if is_opened:
			animated_sprite.play("open")
			monitoring = false  # Disable interaction
