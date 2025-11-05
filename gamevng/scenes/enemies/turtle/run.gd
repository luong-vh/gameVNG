extends EnemyState

@export var patrol_distance: float = 150
@export var pause_time: float = 1.0

var _start_x: float
var _is_paused: bool = false
var _pause_timer: float = 0.0

func _enter() -> void:
	_start_x = obj.global_position.x
	obj.change_animation("walk")

func _update(delta : float) -> void:
	if _is_paused:
		_pause_timer -= delta
		if _pause_timer <= 0:
			obj.turn_around()
			_start_x = obj.global_position.x
			_is_paused = false
		return
	obj.velocity.x = obj.direction * obj.movement_speed * 0.5
	if _should_turn_around():
		_start_pause()

func _should_turn_around() -> bool:
	var current_x = obj.global_position.x
	if abs(current_x - _start_x) >= patrol_distance:
		return true
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false

func _start_pause() -> void:
	_is_paused = true
	_pause_timer = pause_time
	obj.velocity.x = 0
func take_damage(_damage_dir, damage: int) -> void:
	print("[Run State] Hit → go to HideInShell instead")
	var dir_x = _damage_dir.x
	if abs(dir_x) < 0.2:
		dir_x = -obj.direction  
	else:
		dir_x = -sign(dir_x)  
	var knock_x := 260.0
	var knock_y := -240.0
	obj.velocity.x = knock_x * dir_x
	obj.velocity.y = knock_y

	await get_tree().create_timer(0.2).timeout
	obj.take_damage(damage)
	fsm.change_state(fsm.states.hide)   
