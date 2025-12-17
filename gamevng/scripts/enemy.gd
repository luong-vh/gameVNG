class_name EnemyCharacter
extends BaseCharacter

@export var has_key: bool = false
@export var key_scene: PackedScene

@export var coin_reward: int = 3
var is_coin_droped: bool = false
@export var coin_scene: PackedScene

@export_group("Item Drop")
@export var drop_item_scene: PackedScene  # Scene của item sẽ drop (health_potion, etc)
@export_range(0.0, 1.0) var drop_chance: float = 0.0  # Tỉ lệ drop (0 = không drop, 1 = luôn drop)

# Raycast check wall and fall
var front_ray_cast: RayCast2D;
var down_ray_cast: RayCast2D;

var spawn_only_at_night: bool = false
var spawn_point: Vector2

@export var type: String = ""

@export var detection_range: float = 150
var detect_player_ray: RayCast2D;

# detect player area
var detect_player_area: Area2D;
var found_player: Player = null
var player

func _ready() -> void:
	_init_ray_cast()
	_init_detect_player_area()
	_init_hurt_area()
	_add_into_enemy_manager()
	player = GameManager.player
	spawn_point = global_position
	
	died.connect(_on_eneny_died)
	super._ready()
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
func _exit_tree() -> void:
	_delete_from_enemy_manager()

#init ray cast to check wall and fall
func _init_ray_cast():
	if has_node("Direction/FrontRayCast2D"):
		front_ray_cast = $Direction/FrontRayCast2D
	if has_node("Direction/DownRayCast2D"):
		down_ray_cast = $Direction/DownRayCast2D


#init detect player area
func _init_detect_player_area():
	if has_node("PlayerRayCast2D"):
		detect_player_ray = $PlayerRayCast2D

# init hurt area
func _init_hurt_area():
	if has_node("Direction/HurtArea2D"):
		var hurt_area = $Direction/HurtArea2D
		hurt_area.hurt.connect(_on_hurt_area_2d_hurt)

# check touch wall
func is_touch_wall() -> bool:
	if front_ray_cast != null:
		return front_ray_cast.is_colliding()
	return false

# check can fall
func is_can_fall() -> bool:
	if down_ray_cast != null:
		return not down_ray_cast.is_colliding()
	return false

#enable check player in sight
func enable_check_player_in_sight() -> void:
	if(detect_player_ray != null):
		detect_player_ray.disabled = false

#disable check player in sight
func disable_check_player_in_sight() -> void:
	if(detect_player_ray != null):
		detect_player_ray.disabled = true

func despawn():
	pass

func _on_body_entered(_body: CharacterBody2D) -> void:
	found_player = _body
	_on_player_in_sight(_body.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	found_player = null
	_on_player_not_in_sight()

func _on_hurt_area_2d_hurt(_direction: Vector2, _damage: float) -> void:
	_take_damage_from_dir(_direction, _damage)

# called when player is in sight
func _on_player_in_sight(_player_pos: Vector2):
	pass

# called when player is not in sight
func _on_player_not_in_sight():
	pass

func detect_player() -> void:
	if not player or not detect_player_ray:
		return
	
	if not detect_player_ray.enabled:
		return
	
	var dir_to_player = (player.global_position - global_position)
	var distance = dir_to_player.length()
	dir_to_player = dir_to_player.normalized() * min(distance, detection_range)
	detect_player_ray.target_position = dir_to_player
	
	var player_visible = false
	
	if detect_player_ray.is_colliding():
		var collider = detect_player_ray.get_collider()
		# Check if we hit the player directly
		player_visible = collider == player
	
	if player_visible and found_player == null:
		found_player = player
		_on_player_in_sight(player.global_position)
	elif not player_visible and found_player != null:
		found_player = null
		_on_player_not_in_sight()

func _take_damage_from_dir(_damage_dir: Vector2, _damage: float):
	fsm.current_state.take_damage(_damage_dir, _damage)

func change_to_day_behavior():
	push_error("%s must implement 'change_to_day_behavior()'!" % self)
	assert(false, "Abstract method called")

func change_to_night_behavior():
	push_error("%s must implement 'change_to_night_behavior()'!" % self)
	assert(false, "Abstract method called")

func _add_into_enemy_manager():
	push_error("%s must implement '_add_into_enemy_manager()'!" % self)
	assert(false, "Abstract method called")

func _delete_from_enemy_manager():
	push_error("%s must implement '_delete_from_enemy_manager()'!" % self)
	assert(false, "Abstract method called")

func serialize() -> Dictionary:
	return {
		"type": type,
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"hp": health,
		"spawn_only_at_night": spawn_only_at_night,
		"state": fsm.current_state.name,
	}

func apply_serialized(data: Dictionary) -> void:
	global_position = Vector2(data.position.x, data.position.y)
	health = data.hp
	spawn_only_at_night = data.spawn_only_at_night
	if data.has("state"):
		var state_name: String = str(data.state).to_lower()
		
		if fsm.states.has(state_name):
			var state_obj = fsm.states[state_name]
			fsm.change_state(state_obj)
		else:
			push_warning("⚠ FSM state not found: " + state_name)

func drop_key() -> void:
	if not has_key or key_scene == null:
		return
	var key_instance = key_scene.instantiate()
	get_parent().add_child(key_instance)
	key_instance.global_position = global_position

	var tween = create_tween()

	var up_position = global_position + Vector2(0, -50) 
	tween.tween_property(key_instance, "global_position", up_position, 0.3)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)


	var down_position = global_position + Vector2(0, 10)  # Xuống vị trí ban đầu + 10px
	tween.tween_property(key_instance, "global_position", down_position, 0.5)\
			.set_ease(Tween.EASE_IN)\
			.set_trans(Tween.TRANS_BOUNCE)

	has_key = false

func _on_eneny_died():
	_spawn_coins(coin_reward)
	_spawn_item()

func _spawn_coins(amount: int):
	if !coin_scene:
		return

	if is_coin_droped:
		return
	is_coin_droped = true

	for i in amount:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position
		# Thêm vào world với deferred
		get_tree().current_scene.call_deferred("add_child", coin)

		# Use deferred to avoid physics query error
		coin.call_deferred("set_gravity", true)
		coin.call_deferred("apply_impulse", Vector2(randf_range(-100, 100), -200))

func _spawn_item():
	if !drop_item_scene:
		return

	# Kiểm tra tỉ lệ drop
	if randf() > drop_chance:
		return

	# Spawn item
	var item = drop_item_scene.instantiate()
	item.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", item)
	print("[Enemy] Dropped item: ", item.name)
