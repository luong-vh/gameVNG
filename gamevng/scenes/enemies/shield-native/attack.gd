extends EnemyState

@export var attack_movement_speed = 200
@export var attack_time:float = 1.0
@export var time_prepare:float = 0.3
@export var unstuck_distance: float = 3.0

var phase = 0
var has_triggered_wall_hit = false

@onready var front_raycast: RayCast2D = get_node("../../Direction/FrontRayCast2D")

func _enter() -> void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	
	phase = 1
	timer = time_prepare
	obj.velocity.x = 0
	
	has_triggered_wall_hit = false
	front_raycast.enabled = true

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
	front_raycast.enabled = true

func _update(delta: float) -> void:
	if phase == 2 and front_raycast.is_colliding():
		# Trigger the earthquake only once.
		if not has_triggered_wall_hit:
			GameManager.emit_signal("earthquake_triggered", 15.0, 0.4)
			has_triggered_wall_hit = true
		obj.velocity = Vector2.ZERO
		obj.global_position.x -= obj.direction * unstuck_distance
		change_state(fsm.previous_state)
		return

	if update_timer(delta):
		if phase == 2:
			change_state(fsm.previous_state)
		else:
			obj.velocity.x = obj.direction * attack_movement_speed
			timer = attack_time
			phase = 2
