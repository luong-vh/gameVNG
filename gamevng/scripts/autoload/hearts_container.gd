extends HBoxContainer

@onready var HeartGUI := preload("res://scenes/gui/playerHeartGUI.tscn")

func set_max_heart(max: int) -> void:
	var current := get_child_count()

	# Add missing hearts
	if max > current:
		for i in range(max - current):
			add_child(HeartGUI.instantiate())

	# Remove extra hearts
	elif max < current:
		for i in range(current - max):
			get_child(current - 1 - i).queue_free()
