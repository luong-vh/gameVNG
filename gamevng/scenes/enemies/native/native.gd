extends EnemyCharacter

var raycast_right: RayCast2D
var raycast_left: RayCast2D

@onready var coconut_factory = $Direction/CoconutFactory
@export var bullet_speed : float = 150

@export_group("Throw Parameters")
@export var throw_height := 140  
@export var flight_time := 1.5  
@export_group("Target Settings")
@export var target_position := Vector2.ZERO 
@export var position_randomness := 50.0  
@export var move_distance: float = 450

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

func _process(delta: float) -> void:
	detect_player()

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

func _is_attack() -> bool:
	if found_player != null:
		return true
	return false

func throw_coconut() -> void:
	var coconut := coconut_factory.create() as RigidBody2D

	var start_pos = coconut_factory.global_position

	var target_x = start_pos.x + direction * (move_distance + randf_range(-position_randomness, position_randomness))
	var target = Vector2(target_x, start_pos.y)

	var vx = (target.x - start_pos.x) / flight_time

	var vy = -sqrt(2 * throw_height * get_global_gravity())

	coconut.linear_velocity = Vector2(vx, vy)

	print("vx:", vx, " vy:", vy)


func get_global_gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity") as float
