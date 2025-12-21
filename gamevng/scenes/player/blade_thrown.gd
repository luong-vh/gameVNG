extends RigidBody2D

@onready var hit_area = $HitArea2D 

func _ready():
	self.body_entered.connect(_on_body_entered)
	hit_area.body_entered.connect(_on_body_entered)

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()

func _on_body_entered(_body: Node) -> void:
	queue_free()
