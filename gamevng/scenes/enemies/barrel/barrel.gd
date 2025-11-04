extends EnemyCharacter


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const type ="BARREL"

@export var bullet_speed : float = 300
@onready var bullet_factory = $Direction/BulletFactory

@export var day_color = Color(1,1,1,1)
@export var night_color = Color(1,0,0,1)
var behavior ="DAY"

@export_category("Push Settings")
@export var push_speed_multiplier: float = 0.7  # Player chậm lại

var raycast_right: RayCast2D
var raycast_left: RayCast2D

func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Idle)
	if has_node("CheckLeft"):
		raycast_left = $CheckLeft
	if has_node("CheckRight"):
		raycast_right = $CheckRight
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func try_to_push(velocity_x: float,delta: float) ->float:
	if velocity_x == 0:
		return 0
	var raycast = raycast_right if velocity_x > 0 else raycast_left
	if raycast.is_colliding():
		return 0
	else:
		position.x += velocity_x * push_speed_multiplier * delta
		return velocity_x * push_speed_multiplier


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
	behavior = "DAY"
	$Direction/AnimatedSprite2D.modulate = day_color
	fsm.change_state(fsm.states.idle)
func change_to_night_behavior():
	print("[%s] Changed behavior to Night" %self)
	behavior = "NIGHT"
	$Direction/AnimatedSprite2D.modulate = night_color
	fsm.change_state(fsm.states.idle)
