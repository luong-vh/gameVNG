extends EnemyCharacter

@export_group("Flying")
@export var patrol_distance: float = 200.0
var patrol_start: Vector2
var patrol_end: Vector2
#@export var pause_time: float = 0.5

@export_group("Attack")
@export var attack_cool_down: float = 3
@export var shot_amount: int = 1
@export var bullet_speed : float = 30
@onready var bullet_factory = $Direction/BulletFactory

func _ready()->void:
	super._ready()
	type = "PELICAN"
	fsm = FSM.new(self, $States, $States/Fly)
	init_patrol_path()

func init_patrol_path():
	patrol_start = global_position
	patrol_end = Vector2(patrol_start.x + patrol_distance * direction, patrol_start.y)

func fire() -> void:
	var bullet :=bullet_factory.create() as RigidBody2D
	var shooting_velocity := Vector2(0.0, bullet_speed)
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
