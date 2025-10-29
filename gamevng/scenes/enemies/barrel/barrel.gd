extends EnemyCharacter


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const type ="BARREL"

@export var bullet_speed : float = 300
@onready var bullet_factory = $Direction/BulletFactory

func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Idle)

func fire() -> void:
	var bullet :=bullet_factory.create() as RigidBody2D
	var shooting_velocity := Vector2(bullet_speed * direction, 0.0)
	bullet.apply_impulse(shooting_velocity)
	
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
