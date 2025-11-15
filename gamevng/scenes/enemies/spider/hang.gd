extends EnemyState

## Hang state - Spider treo trên trần và kéo player lên
## Port từ logic spider.gd cũ (IDLE/PULLING/HOLDING/COOLDOWN)

enum HangSubState {
	IDLE,       ## Đợi player đi qua
	PULLING,    ## Đang kéo player lên
	HOLDING,    ## Giữ player ở trên
	COOLDOWN    ## Nghỉ sau khi thả player
}

var sub_state: HangSubState = HangSubState.IDLE
var target_player: Player = null
var hold_timer: float = 0.0
var cooldown_timer: float = 0.0
var pull_tween: Tween = null
var spider_tween: Tween = null


func _enter():
	print("[Spider/Hang] Entering HANG state")
	sub_state = HangSubState.IDLE
	obj.behavior_mode = Spider.BehaviorMode.HANGING

	# Enable pull detector
	if obj.pull_detector:
		obj.pull_detector.enabled = true

	# Play idle animation
	obj.change_animation("idle")


func _update(delta: float):
	# Update web line mỗi frame
	_update_web_line()

	# FSM con cho hang behavior
	match sub_state:
		HangSubState.IDLE:
			_sub_state_idle(delta)
		HangSubState.PULLING:
			_sub_state_pulling(delta)
		HangSubState.HOLDING:
			_sub_state_holding(delta)
		HangSubState.COOLDOWN:
			_sub_state_cooldown(delta)


func _exit():
	print("[Spider/Hang] Exiting HANG state")

	# Cleanup
	if pull_tween and pull_tween.is_running():
		pull_tween.kill()
	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	# Release player nếu đang giữ
	if target_player:
		_release_player()

	# Disable pull detector
	if obj.pull_detector:
		obj.pull_detector.enabled = false

	# Ẩn web line
	if obj.web_line:
		obj.web_line.visible = false


## Sub-states logic

func _sub_state_idle(_delta: float) -> void:
	# Check raycast CỐ ĐỊNH thẳng xuống
	if not obj.pull_detector or not obj.pull_detector.enabled:
		return

	if obj.pull_detector.is_colliding():
		var collider = obj.pull_detector.get_collider()

		# Check nếu là player
		if collider is CharacterBody2D and collider.is_in_group("player"):
			print("[Spider/Hang] Detected player below! Starting pull...")
			_start_pulling(collider)


func _sub_state_pulling(_delta: float) -> void:
	# Check nếu pull tween đang chạy
	if pull_tween and pull_tween.is_running():
		return  # Vẫn đang kéo, chờ tiếp

	# Check nếu spider tween đang chạy (nhện đang di chuyển)
	if spider_tween and spider_tween.is_running():
		return  # Nhện đang di chuyển, chờ tiếp

	# Cả 2 tween đều xong → Chuyển sang HOLDING
	if target_player and is_instance_valid(target_player):
		print("[Spider/Hang] Pull complete! Holding player...")
		_change_sub_state(HangSubState.HOLDING)
	else:
		print("[Spider/Hang] Player lost during pull, going to cooldown")
		_change_sub_state(HangSubState.COOLDOWN)


func _sub_state_holding(delta: float) -> void:
	hold_timer -= delta

	if hold_timer <= 0:
		# Hết thời gian hold → Thả player
		print("[Spider/Hang] Releasing player!")
		_release_player()
		_change_sub_state(HangSubState.COOLDOWN)


func _sub_state_cooldown(delta: float) -> void:
	cooldown_timer -= delta

	if cooldown_timer <= 0:
		print("[Spider/Hang] Cooldown finished. Ready to pull again.")
		_change_sub_state(HangSubState.IDLE)


## Pull logic (port từ spider.gd cũ)

func _start_pulling(player_body: CharacterBody2D) -> void:
	target_player = player_body

	print("[Spider/Hang] Starting pull sequence...")

	# QUAN TRỌNG: Chuyển sub-state NGAY để tránh trigger lại
	_change_sub_state(HangSubState.PULLING)

	# LƯU VỊ TRÍ PLAYER NGAY TỪ ĐẦU
	var player_start_position = target_player.global_position

	# Stop player velocity
	target_player.velocity = Vector2.ZERO

	# Disable player gravity temporarily
	if target_player.has_method("set_gravity_enabled"):
		target_player.set_gravity_enabled(false)

	# Tính vị trí nhện cần di chuyển tới (ngay phía trên VỊ TRÍ PLAYER BAN ĐẦU)
	var spider_target_position = player_start_position - obj.pull_offset
	# Convert về local position
	var spider_local_target = obj.get_parent().to_local(spider_target_position) if obj.get_parent() else spider_target_position

	print("[Spider/Hang] Player locked at: ", player_start_position)
	print("[Spider/Hang] Moving spider to position above player: ", spider_local_target)

	# ANIMATION 1: Nhện di chuyển xuống vị trí phía trên player
	_animate_spider_to_position(spider_local_target)

	# Play pull sprite (nếu có)
	if obj.animated_sprite.sprite_frames.has_animation("pull"):
		obj.change_animation("pull")

	# Đợi nhện di chuyển xong
	if spider_tween:
		await spider_tween.finished

	# Check target_player vẫn còn valid
	if not target_player or not is_instance_valid(target_player):
		print("[Spider/Hang] Player no longer valid, aborting pull")
		_change_sub_state(HangSubState.COOLDOWN)
		return

	# QUAN TRỌNG: Check GrabArea có THỰC SỰ chạm player không?
	if not _is_grabbing_player():
		print("[Spider/Hang] Player escaped! Not grabbing player, aborting pull")

		# Nhện quay về vị trí ban đầu
		_animate_spider_ascend()

		# Đổi sprite về idle
		obj.change_animation("idle")

		target_player = null
		_change_sub_state(HangSubState.COOLDOWN)
		return

	print("[Spider/Hang] ✓ Grabbing player! Proceeding to pull...")

	# Emit signal
	obj.player_pulled.emit(target_player)

	# ANIMATION 2: Nhện quay lên VÀ kéo player CÙNG LÚC!
	var pull_destination_global = obj.global_position if not obj.get_parent() else obj.get_parent().to_global(obj.initial_hang_position)
	# Offset xuống một tí để không chạm hitbox
	pull_destination_global += Vector2(0, obj.pull_offset.y / 2)

	var distance = player_start_position.distance_to(pull_destination_global)

	print("[Spider/Hang] Pulling player from ", player_start_position, " to ", pull_destination_global)
	print("[Spider/Hang] Distance: ", distance, "px")
	print("[Spider/Hang] Spider ascending while pulling player...")

	# CÙNG LÚC: Nhện quay lên + Player bị kéo lên
	_animate_spider_ascend()  # Nhện lên
	_animate_pull_player_to(pull_destination_global)  # Player lên (parallel!)

	# Đợi CẢ 2 tween xong
	if spider_tween and pull_tween:
		await spider_tween.finished
		if pull_tween.is_running():
			await pull_tween.finished
	elif pull_tween:
		await pull_tween.finished
	elif spider_tween:
		await spider_tween.finished

	# Check lại target_player
	if not target_player or not is_instance_valid(target_player):
		print("[Spider/Hang] Player lost after pull")
		_change_sub_state(HangSubState.COOLDOWN)
		return

	print("[Spider/Hang] Pull complete! Moving to HOLDING sub-state...")
	_change_sub_state(HangSubState.HOLDING)


func _is_grabbing_player() -> bool:
	"""Check xem GrabArea có đang chạm player không"""
	if not obj.grab_area:
		return true  # Fallback: nếu không có grab_area thì cứ kéo luôn

	var overlapping_bodies = obj.grab_area.get_overlapping_bodies()

	for body in overlapping_bodies:
		if body == target_player:
			return true

	return false


func _animate_spider_to_position(target_pos: Vector2) -> void:
	"""Animation nhện di chuyển đến vị trí cụ thể"""
	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	spider_tween = obj.create_tween()
	spider_tween.set_ease(Tween.EASE_OUT)
	spider_tween.set_trans(Tween.TRANS_CUBIC)
	spider_tween.tween_property(obj, "position", target_pos, obj.descend_speed)


func _animate_pull_player_to(destination: Vector2) -> void:
	"""Animation kéo player đến vị trí cụ thể"""
	if not target_player:
		return

	var distance = target_player.global_position.distance_to(destination)
	var duration = distance / obj.pull_speed

	# Nếu distance quá nhỏ, set duration tối thiểu
	if duration < 0.1:
		duration = 0.1

	if pull_tween and pull_tween.is_running():
		pull_tween.kill()

	pull_tween = obj.create_tween()
	pull_tween.set_ease(Tween.EASE_IN_OUT)
	pull_tween.set_trans(Tween.TRANS_CUBIC)
	pull_tween.tween_property(target_player, "global_position", destination, duration)


func _release_player() -> void:
	if not target_player:
		return

	print("[Spider/Hang] Releasing player...")

	# Re-enable player gravity
	if target_player.has_method("set_gravity_enabled"):
		target_player.set_gravity_enabled(true)

	# Set velocity = 0
	target_player.velocity = Vector2.ZERO

	# Play idle animation
	obj.change_animation("idle")

	# Emit signal
	obj.player_released.emit(target_player)

	target_player = null


func _animate_spider_ascend() -> void:
	"""Animation nhện quay lên vị trí ban đầu"""
	if spider_tween and spider_tween.is_running():
		spider_tween.kill()

	spider_tween = obj.create_tween()
	spider_tween.set_ease(Tween.EASE_IN)
	spider_tween.set_trans(Tween.TRANS_CUBIC)
	spider_tween.tween_property(obj, "position", obj.initial_hang_position, obj.descend_speed)


func _change_sub_state(new_sub_state: HangSubState) -> void:
	print("[Spider/Hang] Sub-state: ", HangSubState.keys()[sub_state], " → ", HangSubState.keys()[new_sub_state])
	sub_state = new_sub_state

	# Reset timers
	match new_sub_state:
		HangSubState.HOLDING:
			hold_timer = obj.hold_duration
		HangSubState.COOLDOWN:
			cooldown_timer = obj.cooldown_duration


func _update_web_line() -> void:
	"""Update sợi tơ mỗi frame"""
	if not obj.web_line:
		return

	# Chỉ hiện sợi tơ khi đang PULLING hoặc HOLDING
	if sub_state == HangSubState.PULLING or sub_state == HangSubState.HOLDING:
		if not obj.web_line.visible:
			print("[Spider/Hang] Showing web line!")
			obj.web_line.visible = true

		# Vẽ line từ vị trí ban đầu (trên trần) xuống vị trí hiện tại (spider)
		obj.web_line.clear_points()
		obj.web_line.add_point(obj.initial_hang_position - obj.position)  # Điểm trên
		obj.web_line.add_point(Vector2.ZERO)  # Điểm dưới (spider = origin)
	else:
		# Ẩn sợi tơ khi IDLE hoặc COOLDOWN
		if obj.web_line.visible:
			obj.web_line.visible = false


## Override take_damage để không bị hurt khi đang treo trên trần
func take_damage(_damage_dir, damage: int) -> void:
	# Spider khi treo trên trần không nhận damage
	print("[Spider/Hang] Cannot be damaged while hanging!")
	pass
