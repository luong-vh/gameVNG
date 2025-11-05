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
	obj.velocity.x = 250 * _damage_dir.x     
	obj.velocity.y = -250 
	await get_tree().create_timer(0.2).timeout
	obj.take_damage(damage)
	fsm.change_state(fsm.states.hide)   
