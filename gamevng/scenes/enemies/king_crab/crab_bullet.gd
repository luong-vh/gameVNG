extends RigidBody2D

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()
