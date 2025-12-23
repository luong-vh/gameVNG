extends RigidBody2D

func _ready() -> void:
	pass

func _on_interactive_area_2d_interaction_available() -> void:
	GameManager.player.collect_powerup("blade")
	queue_free()
	pass
