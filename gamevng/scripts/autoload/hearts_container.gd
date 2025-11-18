extends HBoxContainer

@onready var _heartGUI = preload("res://scenes/gui/playerHeartGUI.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_max_heart(max: int):
	for i in range(max):
		var heart = _heartGUI.instantiate()
		add_child(heart)
