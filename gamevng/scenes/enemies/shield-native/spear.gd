extends EnemyCharacter

const type ="SPEAR"
@export var attack_cooldown: float = 0.5
@export var speed = 100 

var original_speed: float
var original_player_raycast_length: float

func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Moving)
	
	#store default speed
	original_speed = speed
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		original_player_raycast_length = shape.shape.size.x
	
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
	# Restore original speed and detection range
	speed = original_speed
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		shape.shape.size.x = original_player_raycast_length

func change_to_night_behavior():
	print("[%s] Changed behavior to Night" %self)
	# Decrease speed and detection range for night
	speed = original_speed * 0.6 # Reduce speed by 40%
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		shape.shape.size.x = original_player_raycast_length * 0.5 # Reduce detection range by 50%
