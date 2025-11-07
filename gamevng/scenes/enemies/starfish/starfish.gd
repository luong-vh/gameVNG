extends EnemyCharacter


@export var attack_cooldown: float = 0.5
func _ready() -> void:
	super._ready()
	type = "STARFISH"
	fsm = FSM.new(self, $States, $States/Moving)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _process(delta: float) -> void:
	detect_player()
	
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
