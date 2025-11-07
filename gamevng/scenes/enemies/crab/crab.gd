extends EnemyCharacter


const SPEED = 170.0
const JUMP_VELOCITY = -400.0


func _ready()->void:
	super._ready()
	type = "CRAB"
	fsm = FSM.new(self, $States, $States/Run)
	
func _add_into_enemy_manager():
	EnemyManager.add_enemy(self,type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self,type)

func change_to_day_behavior():
	print("[%s] Changed behavior to DAY" %self)
	#Todo: Implememt logic to change behavior

func change_to_night_behavior():
	print("[%s] Changed behavior to Night" %self)
	#Todo: Implememt logic to change behavior
