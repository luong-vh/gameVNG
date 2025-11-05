extends EnemyCharacter

const type = "TURTLE"
func _ready() -> void:
	fsm = FSM.new(self , $States ,$States/Run)
	_add_into_enemy_manager()
	super._ready()


func _add_into_enemy_manager():
	EnemyManager.add_enemy(self , type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self , type)

func change_to_day_behavior():
	pass


func change_to_night_behavior():
	pass
