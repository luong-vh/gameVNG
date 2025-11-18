extends TextureProgressBar

@onready var enemy = self.get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.healthChanged.connect(_update_progress)
	_update_progress()

func _update_progress():
	value = enemy.health * 100.0 / enemy.max_health
