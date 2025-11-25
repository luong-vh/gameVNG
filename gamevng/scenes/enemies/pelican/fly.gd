extends EnemyState

var _start_x: float
var _is_paused: bool = false
var _pause_timer: float = 0.0

func _enter()->void:
	_start_x = obj.global_position.x
	obj.change_animation("fly")
	timer = 3
	_is_paused = false
	_pause_timer = 0.0

func _update(delta: float)->void:
	# Handle pause state
	if _is_paused:
		_pause_timer -= delta
		if _pause_timer <= 0:
			obj.turn_around()
			_start_x = obj.global_position.x
			_is_paused = false
		obj.velocity.x = 0
		return

	# Normal flying movement
	obj.velocity.x = obj.direction * obj.SPEED

	# Check if should turn around
	if _should_turn_around():
		_start_pause()

	# Attack timer
	if update_timer(delta):
		change_state(fsm.states.attack)

func _should_turn_around() -> bool:
	# Check if exceeded patrol distance
	var current_x = obj.global_position.x
	if abs(current_x - _start_x) >= obj.patrol_distance:
		return true

	# Check if hit wall
	if obj.is_touch_wall():
		return true

	return false

func _start_pause() -> void:
	_is_paused = true
	_pause_timer = obj.pause_time
	obj.velocity.x = 0
