class_name EnemyCharacter
extends BaseCharacter


# Raycast check wall and fall
var front_ray_cast: RayCast2D;
var down_ray_cast: RayCast2D;

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
	super._ready()
	pass

	
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
