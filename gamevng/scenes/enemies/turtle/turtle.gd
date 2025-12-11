extends EnemyCharacter

@export_category("Push Settings")
@export var push_speed_multiplier: float = 0.7 

var raycast_right: RayCast2D
var raycast_left: RayCast2D
func _ready() -> void:
	fsm = FSM.new(self , $States ,$States/Run)
	type = "TURTLE"
	spawn_only_at_night = true
	spawn_point = global_position
	if has_node("CheckLeft"):
		raycast_left = $CheckLeft
	if has_node("CheckRight"):
		raycast_right = $CheckRight
	super._ready()

func try_to_push(velocity_x: float,delta: float) ->float:
	if fsm.current_state == fsm.states.inshell:
		if velocity_x == 0:
			return 0
		var raycast = raycast_right if velocity_x > 0 else raycast_left
		if raycast.is_colliding():
			return 0
		else:
			position.x += velocity_x * push_speed_multiplier * delta
			return velocity_x * push_speed_multiplier
	return 0

func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	print("[%s] → DAY: hide turtle" % name)
	_delete_from_enemy_manager()
	queue_free()

func change_to_night_behavior():
	print("[%s] → NIGHT: (spawn handled by manager)" % name)
	pass
