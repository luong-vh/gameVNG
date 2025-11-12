extends EnemyCharacter

var raycast_right: RayCast2D
var raycast_left: RayCast2D


func _ready() -> void:
	fsm = FSM.new(self , $States ,$States/Walk)
	type = "NATIVE"
	spawn_only_at_night = false
	spawn_point = global_position
	if has_node("CheckLeft"):
		raycast_left = $CheckLeft
	if has_node("CheckRight"):
		raycast_right = $CheckRight
	super._ready()


func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	print("[%s] → DAY:  (spawn handled by manager)" % name)




func change_to_night_behavior():
	print("[%s] → NIGHT: Hide Native")
	_delete_from_enemy_manager()
	queue_free()
	pass
