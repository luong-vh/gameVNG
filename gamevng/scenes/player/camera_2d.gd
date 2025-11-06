extends Camera2D

var _is_shaking: bool = false
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0

func _ready() -> void:
	# Connect to the global earthquake signal
	GameManager.earthquake_triggered.connect(start_shake)

func start_shake(strength: float, duration: float) -> void:
	if _is_shaking:
		return
	_shake_strength = strength
	_shake_duration = duration
	_is_shaking = true

func _process(delta: float) -> void:
	if _is_shaking:
		# Generate random offset
		var offset_x = randf_range(-_shake_strength, _shake_strength)
		var offset_y = randf_range(-_shake_strength, _shake_strength)
		offset = Vector2(offset_x, offset_y)
		
		# Countdown duration
		_shake_duration -= delta
		if _shake_duration <= 0:
			_is_shaking = false
			offset = Vector2.ZERO # Reset camera offset
