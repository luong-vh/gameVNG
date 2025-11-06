class_name Player
extends BaseCharacter

var lock_input_timer: Timer

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
@onready var invulnerable_timer = $InvulnerableTimer

@export var throwing_speed: float = 300
@export var has_blade: bool = false
@onready var hit_area_collision
@onready var blade_factory = $Direction/BladeFactory

## For wall jump and cling
var wall_checker: RayCast2D
@export var wall_friction: float = 300.0
@export var wall_jump_force: float = 120.0
@export var wall_slide_speed: float = 200.0

## For double jump
var jump_count = 1
@export var max_jump_amount = 1

var raycast_pushable: RayCast2D

func _ready() -> void:
	super._ready()
	set_animated_sprite($Direction/AnimatedSprite2D)
	fsm = FSM.new(self, $States, $States/Idle)
	if has_blade:
		collect_blade()
	
	if has_node("LockInputTimer"):
		lock_input_timer = get_node("LockInputTimer")
	
	_init_hit_hurt_area()
	_init_wall_cling()
	
	GameManager.player = self
	Dialogic.VAR["PlayerHasBlade"] = has_blade
	
	if has_node("Direction/CheckPushable"):
		raycast_pushable = $Direction/CheckPushable

func _init_wall_cling():
	## Setup wall cling
	if has_node("Direction/WallChecker"):
		wall_checker = get_node("Direction/WallChecker")
	else:
		print("Has no wall checker")

func _init_hit_hurt_area():
	if has_node("Direction/HitArea2D") and has_node("Direction/HitArea2D/CollisionShape2D"):
		hit_area_collision = $Direction/HitArea2D/CollisionShape2D
		hit_area_collision.disabled = true
	else:
		print("Fail to init hit area")
	
	if has_node("Direction/HurtArea2D"):
		$Direction/HurtArea2D.hurt.connect(_on_hurt_area_2d_hurt)
	else:
		print("Fail to init hurt area")
	

func can_attack() -> bool:
	return has_blade

func collect_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = true

func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y],
		"has_blade": [has_blade],
		"health": [health]
	}

func is_near_wall() -> bool:
	if wall_checker:
		return wall_checker.is_colliding()
	else:
		return false

func lock_input() -> bool:
	if lock_input_timer:
		lock_input_timer.start()
		return true
	else:
		return false

func is_input_lock() -> bool:
	return lock_input_timer.time_left > 0

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	#print(data)
	if data.has("position"):
		print("loaded position")
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
	
	if data.has("has_blade"):
		print("loaded has_blade")
		has_blade = data["has_blade"][0]
		if has_blade:
			collect_blade()
	
	if data.has("health"):
		health = data["health"][0]
		print("loaded health %d" %health)
	fsm.change_state(fsm.states.idle)

func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)

func invulnerable()->void:
	is_invulnerable = true
	invulnerable_timer.start()
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_day_night"):
		DayNightManager.switch_state()
	
	if invulnerable_timer.is_stopped():
		is_invulnerable = false
	
	if Input.is_action_just_pressed("attack"):
		if can_attack(): 
			fsm.change_state(fsm.states.attack)
	
	if Input.is_action_just_pressed("throw"):
		if can_attack():
			has_blade = false
			Dialogic.VAR["PlayerHasBlade"] = false
			set_animated_sprite($Direction/AnimatedSprite2D)
			change_animation("idle")
			var blade := blade_factory.create() as RigidBody2D
			var throwing_velocity := Vector2(throwing_speed * direction, 0.0)
			blade.apply_impulse(throwing_velocity)
			
	super._physics_process(delta)
