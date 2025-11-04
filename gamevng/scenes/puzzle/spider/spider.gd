extends Node2D
class_name Spider

## Spider - Hazard/Trap
## Kéo player lên cao, thả ra để player tận dụng double jump

## States
enum State {
	IDLE,       ## Đợi player đi qua
	PULLING,    ## Đang kéo player lên
	HOLDING,    ## Giữ player ở trên
	COOLDOWN    ## Nghỉ sau khi thả player
}

## Export variables
@export var pull_speed: float = 300.0  ## Tốc độ kéo player lên (pixels/giây)
@export var hold_duration: float = 0.5  ## Giữ player bao lâu trước khi thả (giây)
@export var cooldown_duration: float = 2.0  ## Cooldown sau khi thả (giây)
@export var pull_offset: Vector2 = Vector2(0, 16)  ## Offset từ vị trí player (nhện ở phía trên player bao nhiêu)
@export var descend_speed: float = 0.3  ## Tốc độ nhện hạ xuống/lên (giây)
@export var detection_range: float = 200.0  ## Tầm phát hiện player (pixels)

## Signals
signal player_pulled(player: Node2D)
signal player_released(player: Node2D)

## State
var current_state: State = State.IDLE
var target_player: Player = null
var hold_timer: float = 0.0
var cooldown_timer: float = 0.0
var pull_tween: Tween = null
var spider_tween: Tween = null  ## Tween để di chuyển spider lên/xuống
var initial_position: Vector2  ## Vị trí ban đầu của spider
var player: Player = null  ## Reference to player

## Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pull_detector: RayCast2D = $PullDetector
@onready var hit_area: Area2D = $HitArea2D if has_node("HitArea2D") else null
@onready var grab_area: Area2D = $GrabArea2D if has_node("GrabArea2D") else null
@onready var web_line: Line2D = $WebLine if has_node("WebLine") else null


func _ready() -> void:
	print("[Spider] Initialized at position: ", global_position)

	# Lưu vị trí ban đầu
	initial_position = position

	# Get player reference
	player = GameManager.player

	# Setup raycast
	if pull_detector:
		pull_detector.enabled = true

	# Setup web line (ẩn ban đầu)
	if web_line:
		web_line.visible = false
		print("[Spider] WebLine found! Width: ", web_line.width, " Color: ", web_line.default_color)
	else:
		print("[Spider] WARNING: WebLine node NOT found! Add a Line2D node named 'WebLine' to the spider scene")

	# Play idle animation
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")




func _process(_delta: float) -> void:
	# Update sợi tơ mỗi frame
	_update_web_line()


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PULLING:
			_state_pulling(delta)
		State.HOLDING:
			_state_holding(delta)
		State.COOLDOWN:
			_state_cooldown(delta)


func _state_idle(_delta: float) -> void:
	# Check raycast CỐ ĐỊNH thẳng xuống
	if not pull_detector or not pull_detector.enabled:
		return

	if pull_detector.is_colliding():
		var collider = pull_detector.get_collider()

		# Check nếu là player
		if collider is CharacterBody2D and collider.is_in_group("player"):
			print("[Spider] Detected player below! Starting pull...")
			_start_pulling(collider)


func _state_pulling(_delta: float) -> void:
	# Check nếu pull tween đang chạy
	if pull_tween and pull_tween.is_running():
		return  # Vẫn đang kéo, chờ tiếp

	# Check nếu spider tween đang chạy (nhện đang di chuyển)
	if spider_tween and spider_tween.is_running():
		return  # Nhện đang di chuyển, chờ tiếp

	# Cả 2 tween đều xong → Chuyển sang HOLDING
	if target_player and is_instance_valid(target_player):
		print("[Spider] Pull complete! Holding player...")
		_change_state(State.HOLDING)
	else:
		print("[Spider] Player lost during pull, going to cooldown")
		_change_state(State.COOLDOWN)


func _state_holding(delta: float) -> void:
	hold_timer -= delta

	if hold_timer <= 0:
		# Hết thời gian hold → Thả player
		print("[Spider] Releasing player!")
		_release_player()
		_change_state(State.COOLDOWN)


func _state_cooldown(delta: float) -> void:
	cooldown_timer -= delta

	if cooldown_timer <= 0:
		print("[Spider] Cooldown finished. Ready to pull again.")
		_change_state(State.IDLE)


func _start_pulling(player_body: CharacterBody2D) -> void:
	target_player = player_body

	print("[Spider] Starting pull sequence...")

	# QUAN TRỌNG: Chuyển state NGAY để tránh trigger lại
	_change_state(State.PULLING)

	# LƯU VỊ TRÍ PLAYER NGAY TỪ ĐẦU (trước khi bất cứ thứ gì)
	var player_start_position = target_player.global_position

	# Stop player velocity
	target_player.velocity = Vector2.ZERO

	# Disable player gravity temporarily (nếu có property này)
	if target_player.has_method("set_gravity_enabled"):
		target_player.set_gravity_enabled(false)

	# Tính vị trí nhện cần di chuyển tới (ngay phía trên VỊ TRÍ PLAYER BAN ĐẦU)
	var spider_target_position = player_start_position - pull_offset
	# Convert về local position
	var spider_local_target = get_parent().to_local(spider_target_position) if get_parent() else spider_target_position

	print("[Spider] Player locked at: ", player_start_position)
	print("[Spider] Moving spider to position above player: ", spider_local_target)

	# ANIMATION 1: Nhện di chuyển xuống vị trí phía trên player
	_animate_spider_to_position(spider_local_target)

	# Play pull sprite
	if animated_sprite.sprite_frames.has_animation("pull"):
		animated_sprite.play("pull")

	# Đợi nhện di chuyển xong (await tween finished)
	if spider_tween:
		await spider_tween.finished

	# Check target_player vẫn còn valid
	if not target_player or not is_instance_valid(target_player):
		print("[Spider] Player no longer valid, aborting pull")
		_change_state(State.COOLDOWN)
		return

	# QUAN TRỌNG: Check GrabArea có THỰC SỰ chạm player không?
	if not _is_grabbing_player():
		print("[Spider] Player escaped! Not grabbing player, aborting pull")

		# Nhện quay về vị trí ban đầu
		_animate_spider_ascend()

		# Đổi sprite về idle
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

		target_player = null
		_change_state(State.COOLDOWN)
		return

	print("[Spider] ✓ Grabbing player! Proceeding to pull...")

	# Emit signal
	player_pulled.emit(target_player)

	# ANIMATION 2: Nhện quay lên VÀ kéo player CÙNG LÚC!
	# Pull destination = initial spider position (vị trí nhện trước khi di chuyển xuống)
	var pull_destination_global = global_position if not get_parent() else get_parent().to_global(initial_position)
	# Offset xuống một tí để không chạm hitbox
	pull_destination_global += Vector2(0, pull_offset.y / 2)

	var distance = player_start_position.distance_to(pull_destination_global)

	print("[Spider] Pulling player from ", player_start_position, " to ", pull_destination_global)
	print("[Spider] Distance: ", distance, "px")
	print("[Spider] Spider ascending while pulling player...")

	# CÙNG LÚC: Nhện quay lên + Player bị kéo lên
	_animate_spider_ascend()  # Nhện lên
	_animate_pull_player_to(pull_destination_global)  # Player lên (parallel!)

	# Đợi CẢ 2 tween xong (lấy cái dài hơn)
	if spider_tween and pull_tween:
		# Đợi cả 2 xong
		await spider_tween.finished
		if pull_tween.is_running():
			await pull_tween.finished
	elif pull_tween:
		await pull_tween.finished
	elif spider_tween:
		await spider_tween.finished

	# Check lại target_player
	if not target_player or not is_instance_valid(target_player):
		print("[Spider] Player lost after pull")
		_change_state(State.COOLDOWN)
		return

	print("[Spider] Pull complete! Moving to HOLDING state...")
	_change_state(State.HOLDING)


func _is_grabbing_player() -> bool:
	"""Check xem GrabArea có đang chạm player không"""
	if not grab_area:
		print("[Spider] No GrabArea2D found, skipping grab check")
		return true  # Fallback: nếu không có grab_area thì cứ kéo luôn

	# Get tất cả bodies trong grab area
	var overlapping_bodies = grab_area.get_overlapping_bodies()

	# Check có player không
	for body in overlapping_bodies:
		if body == target_player:
			return true

	return false


func _animate_spider_to_position(target_pos: Vector2) -> void:
	"""Animation nhện di chuyển đến vị trí cụ thể"""
	# Kill old tween if exists
	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	# Tween spider position đến target
	spider_tween = create_tween()
	spider_tween.set_ease(Tween.EASE_OUT)
	spider_tween.set_trans(Tween.TRANS_CUBIC)
	spider_tween.tween_property(self, "position", target_pos, descend_speed)


func _animate_pull_player_to(destination: Vector2) -> void:
	"""Animation kéo player đến vị trí cụ thể"""
	if not target_player:
		return

	# Calculate distance and duration
	var distance = target_player.global_position.distance_to(destination)
	var duration = distance / pull_speed

	print("[Spider] Pull tween - Distance: ", distance, "px | Duration: ", duration, "s")

	# Nếu distance quá nhỏ, set duration tối thiểu
	if duration < 0.1:
		duration = 0.1

	# Kill old tween if exists
	if pull_tween and pull_tween.is_running():
		pull_tween.kill()

	# Tween player position
	pull_tween = create_tween()
	pull_tween.set_ease(Tween.EASE_IN_OUT)
	pull_tween.set_trans(Tween.TRANS_CUBIC)
	pull_tween.tween_property(target_player, "global_position", destination, duration)


func _release_player() -> void:
	if not target_player:
		return

	print("[Spider] Releasing player...")

	# Re-enable player gravity (nếu đã disable)
	if target_player.has_method("set_gravity_enabled"):
		target_player.set_gravity_enabled(true)

	# Set velocity = 0, để player rơi tự nhiên theo gravity
	target_player.velocity = Vector2.ZERO

	# Nhện đã ở vị trí ban đầu rồi, KHÔNG cần quay lên nữa!

	# Play idle animation
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

	# Emit signal
	player_released.emit(target_player)

	print("[Spider] Player released at position: ", target_player.global_position)

	target_player = null


func _animate_spider_ascend() -> void:
	"""Animation nhện quay lên vị trí ban đầu"""
	# Kill old tween if exists
	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	# Tween spider position về initial
	spider_tween = create_tween()
	spider_tween.set_ease(Tween.EASE_IN)
	spider_tween.set_trans(Tween.TRANS_CUBIC)
	spider_tween.tween_property(self, "position", initial_position, descend_speed)


func _change_state(new_state: State) -> void:
	print("[Spider] State: ", State.keys()[current_state], " → ", State.keys()[new_state])
	current_state = new_state

	# Reset timers
	match new_state:
		State.HOLDING:
			hold_timer = hold_duration
		State.COOLDOWN:
			cooldown_timer = cooldown_duration


func _update_web_line() -> void:
	"""Update sợi tơ mỗi frame"""
	if not web_line:
		return

	# Chỉ hiện sợi tơ khi spider đang PULLING hoặc HOLDING
	if current_state == State.PULLING or current_state == State.HOLDING:
		if not web_line.visible:
			print("[Spider] Showing web line!")
			web_line.visible = true

		# Vẽ line từ vị trí ban đầu (trên trần) xuống vị trí hiện tại (spider)
		# Points phải relative to spider's current position
		# Point 0: Offset từ vị trí hiện tại lên vị trí ban đầu (trên trần)
		# Point 1: Vị trí spider hiện tại (origin của Line2D)
		web_line.clear_points()
		web_line.add_point(initial_position - position)  # Điểm trên (relative to current pos)
		web_line.add_point(Vector2.ZERO)                 # Điểm dưới (spider = origin)
	else:
		# Ẩn sợi tơ khi IDLE hoặc COOLDOWN
		if web_line.visible:
			web_line.visible = false


## Public methods
func reset() -> void:
	"""Reset về trạng thái ban đầu"""
	if pull_tween and pull_tween.is_running():
		pull_tween.kill()

	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	if target_player:
		_release_player()

	# Đưa spider về vị trí ban đầu
	position = initial_position

	current_state = State.IDLE
	hold_timer = 0.0
	cooldown_timer = 0.0

	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

	print("[Spider] Reset to IDLE state")


func force_release() -> void:
	"""Force thả player (ví dụ: khi player chết)"""
	if current_state == State.PULLING or current_state == State.HOLDING:
		_release_player()
		_change_state(State.COOLDOWN)
