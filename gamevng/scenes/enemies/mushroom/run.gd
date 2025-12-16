extends EnemyState

var _start_x: float
var _is_paused: bool = false
var _pause_timer: float = 0.0

func _enter() ->void:
	_start_x = obj.global_position.x
	obj.change_animation("idle")

func _update(delta : float) -> void:
	if _is_paused:
		_pause_timer -= delta
		if _pause_timer <= 0:
			obj.turn_around()
			_start_x = obj.global_position.x
			_is_paused = false
		return
	obj.velocity.x = obj.direction * obj.movement_speed
	if _should_turn_around():
		_start_pause()

func _should_turn_around() -> bool:
	var current_x = obj.global_position.x
	if abs(current_x - _start_x) >= obj.patrol_distance:
		return true
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false

func _start_pause() -> void:
	_is_paused = true
	_pause_timer = obj.pause_time
	obj.velocity.x = 0
