extends RigidBody2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()

func _on_body_entered(_body: Node) -> void:
	queue_free()
