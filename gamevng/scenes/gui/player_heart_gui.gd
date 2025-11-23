extends Panel

@onready var _sprite = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sprite.frame = 0


func update(isAvailable: bool):
	_sprite.frame = 0 if isAvailable else 1
