extends Camera2D
class_name MainCamera

@export_group("Follow Settings")
@export var camera_follow_speed: float = 2
@export var use_smooth_follow: bool = false
@export var max_distance_horizontal:float = 190.0
@export var min_distance_horizontal:float = 10
@export var max_distance_vertical:float = 100.0
@export var min_distance_vertical:float = 10

@export_group("Shake Settings")
@export var shake_decay_rate: float = 3.0  # How fast shake diminishes

@export_group("Look Settings")
@export var look_offset: float = 100.0
@export var look_speed: float = 5.0
@export var look_hold_time: float = 0.3  # Time to hold before looking

## Camera shake state
var _is_shaking: bool = false
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO

## Look offset state
var _current_look_offset: float = 0.0
var _target_look_offset: float = 0.0
var _look_hold_timer: float = 0.0
var _current_look_action: String = ""

## Follow camera
var stop_zone_checks: Dictionary = {}
var camera_locked:bool = false
var is_too_far: bool = false

## Base offset to preserve initial settings
var _base_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameManager.main_camera = self
	_base_offset = offset
	
	# Connect to signals
	if GameManager.earthquake_triggered.is_connected(start_shake):
		GameManager.earthquake_triggered.disconnect(start_shake)
	GameManager.earthquake_triggered.connect(start_shake)
	
	_init_stop_zone_check()
	
	if GameManager.player:
		global_position = GameManager.player.global_position

func _init_stop_zone_check():
	stop_zone_checks.clear()
	var parent = get_node_or_null("StopZoneCheck")
	if parent:
		for dir_node in parent.get_children():
			if dir_node is Node2D:
				var dir_name = dir_node.name.replace("Check", "").to_lower()
				stop_zone_checks[dir_name] = []
				
				for child in dir_node.get_children():
					if child is RayCast2D:
						stop_zone_checks[dir_name].append(child)

func _physics_process(delta: float) -> void:
	handle_follow_player(delta)
	handle_look_offset(delta)
	handle_shaking(delta)
	apply_camera_offset()

func handle_follow_player(delta: float) -> void:
	if not is_instance_valid(GameManager.player):
		return
	
	var target_pos: Vector2 = GameManager.player.global_position
	var move_vector: Vector2 = target_pos - global_position
	
	var stop_info = is_in_stop_zone()
	if is_player_too_far():
		camera_locked = false
		is_too_far = true
	elif stop_info.in_stop_zone:
		camera_locked = true
	
	if is_too_far and camera_locked:
		if not is_player_near():
			camera_locked = false
		else:
			is_too_far = false
	
	if camera_locked:
		var normal = stop_info.normal
		var correction = stop_info.correction
		
		# --- BLOCK MOVEMENT INTO THE WALL ---
		if normal.x != 0 and sign(move_vector.x) == -sign(normal.x):
			move_vector.x = 0
		if normal.y != 0 and sign(move_vector.y) == -sign(normal.y):
			move_vector.y = 0
		
		# --- PUSH CAMERA TO THE EXACT EDGE ---
		if (correction.x < max_distance_horizontal - 20):
			move_vector += correction
	
	if not stop_info.in_stop_zone:
		camera_locked = false
	
	# Apply movement
	var new_pos = global_position + move_vector
	if use_smooth_follow:
		global_position = global_position.lerp(new_pos, camera_follow_speed * delta)
	else:
		global_position = new_pos

func is_in_stop_zone() -> Dictionary:
	var result = {
		"in_stop_zone": false,
		"normal": Vector2.ZERO,
		"correction": Vector2.ZERO,
		"direction": ""
	}
	
	for dir_name in stop_zone_checks.keys():
		for ray: RayCast2D in stop_zone_checks[dir_name]:
			if ray.is_colliding():
				var hit_point: Vector2 = ray.get_collision_point()
				result.direction = dir_name
				result.in_stop_zone = true
				result.normal = ray.get_collision_normal()
				
				var ray_tip: Vector2 = ray.global_position + ray.target_position
				var correction_vec = Vector2(
						(hit_point.x - ray_tip.x), 
						(hit_point.y - ray_tip.y)
					)
				result.correction = correction_vec
				
				return result  # stop at first collision
	return result



func is_player_too_far() -> bool:
	var dx = abs(global_position.x - GameManager.player.global_position.x)
	var dy = abs(global_position.y - GameManager.player.global_position.y)

	var on_x = max_distance_horizontal
	var off_x = max_distance_horizontal * 0.8

	var on_y = max_distance_vertical
	var off_y = max_distance_vertical * 0.8

	# Hysteresis: return true if outside max, false if inside min
	if dx > on_x or dy > on_y:
		return true
	elif dx < off_x and dy < off_y:
		return false
	return false

func is_player_near() -> bool:
	var dx = abs(global_position.x - GameManager.player.global_position.x)
	var dy = abs(global_position.y - GameManager.player.global_position.y)

	return dx < min_distance_horizontal and dy < min_distance_vertical

func handle_look_offset(delta: float) -> void:
	if not GameManager.player:
		return
	
	var is_standing_still = abs(GameManager.player.velocity.x) < 0.1
	if not is_standing_still or not GameManager.player.is_on_floor():
		return
	
	# Check which action is pressed
	var action_pressed := ""
	if Input.is_action_pressed("down"):
		action_pressed = "down"
	elif Input.is_action_pressed("up"):
		action_pressed = "up"
	
	# Handle hold timer
	if action_pressed != "":
		# If same action continues, increment timer
		if action_pressed == _current_look_action:
			_look_hold_timer += delta
			
			# Only activate look after holding for required time
			if _look_hold_timer >= look_hold_time:
				if action_pressed == "down":
					_target_look_offset = look_offset
				elif action_pressed == "up":
					_target_look_offset = -look_offset
		else:
			# New action started, reset timer
			_current_look_action = action_pressed
			_look_hold_timer = 0.0
	else:
		# No action pressed, reset everything
		_current_look_action = ""
		_look_hold_timer = 0.0
		_target_look_offset = 0.0
	
	# Smooth interpolation
	_current_look_offset = lerp(_current_look_offset, _target_look_offset, look_speed * delta)

func handle_shaking(delta: float) -> void:
	if not _is_shaking:
		# Smoothly return shake offset to zero
		_shake_offset = _shake_offset.lerp(Vector2.ZERO, shake_decay_rate * delta)
		return
	
	# Generate random shake offset
	_shake_offset = Vector2(
		randf_range(-_shake_strength, _shake_strength),
		randf_range(-_shake_strength, _shake_strength)
	)
	
	# Decay shake strength over time for more natural feel
	_shake_strength = lerp(_shake_strength, 0.0, shake_decay_rate * delta)
	
	# Countdown duration
	_shake_duration -= delta
	if _shake_duration <= 0:
		_is_shaking = false
		_shake_strength = 0.0

func apply_camera_offset() -> void:
	"""Combine all offsets: base + look + shake"""
	offset = _base_offset + Vector2(0, _current_look_offset) + _shake_offset

func start_shake(strength: float, duration: float) -> void:
	"""Start camera shake effect"""
	# Allow stacking shakes by adding strength
	if _is_shaking:
		_shake_strength = max(_shake_strength, strength)
		_shake_duration = max(_shake_duration, duration)
	else:
		_shake_strength = strength
		_shake_duration = duration
		_is_shaking = true

func look_down() -> void:
	"""Move camera down to look below"""
	_target_look_offset = look_offset

func look_up() -> void:
	"""Move camera up to look above"""
	_target_look_offset = -look_offset

func reset_look() -> void:
	"""Return camera to center position"""
	_target_look_offset = 0.0

func set_look_offset_custom(y_offset: float) -> void:
	"""Set custom look offset"""
	_target_look_offset = clamp(y_offset, -look_offset * 2, look_offset * 2)

func stop_shake() -> void:
	"""Immediately stop shaking"""
	_is_shaking = false
	_shake_strength = 0.0
	_shake_duration = 0.0
	_shake_offset = Vector2.ZERO
