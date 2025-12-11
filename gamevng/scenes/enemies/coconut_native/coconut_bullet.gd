extends RigidBody2D

@onready var hit_area = $HitArea2D 

func _ready():
	hit_area.body_entered.connect(_on_body_entered)

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	_explode()

func _on_body_entered(_body: Node) -> void:
	_explode()


func _explode() -> void:
	# TODO: add effect
	queue_free()
