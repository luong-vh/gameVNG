extends Area2D
class_name GroundCheckPointArea

func _ready() -> void:
	# Connect the signal in _ready, not _init
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	GameManager._last_ground_checkpoint = self
