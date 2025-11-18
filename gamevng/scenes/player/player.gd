class_name Player
extends BaseCharacter

var lock_input_timer: Timer
var light_source: Light2D

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
@onready var invulnerable_timer = $InvulnerableTimer
var blink_speed: int = 3

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
@onready var jump_particle = $Particle/JumpParticle
@export var normal_jump_cost:float = 1
@export var  double_jump_cost:float = 2

## For dash
@export var dash_time: float = 0.2
@export var dash_speed := 600.0
@export var dash_amount: int = 1
var dash_count:int = 0
@onready var dash_particle: GPUParticles2D = $Particle/DashParticle
@onready var dash_timer: Timer = $DashCoolDownTimer

@export var look_down_distance = 50.0   # Khoảng cách camera hạ xuống (pixel)
@export var look_down_forward = 30.0    # Camera tiến lên phía trước
@export var look_speed = 0.1  
@export var _target_offset = Vector2(0,-75)
@onready var camera_2d = $Camera2D
var raycast_pushable: RayCast2D

func _ready() -> void:
	super._ready()
	set_animated_sprite($Direction/AnimatedSprite2D)
	fsm = FSM.new(self, $States, $States/Idle)
	if has_blade:
		collect_blade()
	
	if has_node("LockInputTimer"):
		lock_input_timer = get_node("LockInputTimer")
	
	if has_node("Light2D"):
		light_source = get_node("Light2D")
	
	_init_hit_hurt_area()
	_init_wall_cling()
	
	GameManager.set_player(self)
	GUIManager.set_max_heart_gui(max_health)
	GameManager.main_camera = $Camera2D
	Dialogic.VAR["PlayerHasBlade"] = has_blade
	
	if has_node("Direction/CheckPushable"):
		raycast_pushable = $Direction/CheckPushable
		
	DayNightManager.state_changed.connect(_day_night_changed)
	DayNightManager.shader_stage_changed.connect(_shader_changed)

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
		var hurt_area = $Direction/HurtArea2D
		hurt_area.hurt.connect(_on_take_damge)
	else:
		print("Fail to init hurt area")

func _day_night_changed(new_state):
	if light_source:
		if new_state == DayNightManager.DayNightState.DAY:
			light_source.enabled = false
		elif new_state == DayNightManager.DayNightState.NIGHT:
			light_source.enabled = true
	pass

func _shader_changed(new_state):
	if light_source:
		if new_state == DayNightManager.ShaderState.NONE:
			light_source.enabled = false
		else:
			light_source.enabled = true
	pass

func can_attack() -> bool:
	return has_blade

func collect_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = true
	
func drop_blade():
	has_blade = false
	set_animated_sprite($Direction/AnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = false

func throw_blade():
	var blade := blade_factory.create() as RigidBody2D
	var throwing_velocity := Vector2(throwing_speed * direction, 0.0)
	blade.apply_impulse(throwing_velocity)
	has_blade = false
	Dialogic.VAR["PlayerHasBlade"] = false
	set_animated_sprite($Direction/AnimatedSprite2D)
	change_animation("idle")


func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y],
		"has_blade": [has_blade],
		"health": [max_health]
	}

func is_near_wall() -> bool:
	if wall_checker:
		return wall_checker.is_colliding()
	else:
		return false

func lock_input(length: float = 0.3) -> bool:
	if lock_input_timer:
		lock_input_timer.start(length)
		return true
	else:
		return false

func is_input_lock() -> bool:
	return lock_input_timer.time_left > 0

func start_dash_cd() -> bool:
	if dash_timer:
		dash_timer.start()
		return true
	return false

func is_dash_on_cd() -> bool:
	return dash_timer.time_left > 0

func invulnerable()->void:
	is_invulnerable = true
	invulnerable_timer.start()

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
		else:
			drop_blade()
	
	if data.has("health"):
		health = data["health"][0]
		print("loaded health %d" %health)
		healthChanged.emit()
	fsm.change_state(fsm.states.idle)

func _on_take_damge(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)

func handle_look_down(delta):
	var target_offset = _target_offset

	if Input.is_action_pressed("down"):
		target_offset.y = _target_offset.y + look_down_distance  # SET thành base + look
		target_offset.x = _target_offset.x + (look_down_forward * direction)

	camera_2d.position = camera_2d.position.lerp(target_offset, look_speed)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	handle_look_down(delta)
	if invulnerable_timer.time_left > 0:
		var alpha := 0.5 + 0.5 * sin(invulnerable_timer.time_left * TAU * blink_speed)
		animated_sprite.modulate.a = alpha
	else:
		animated_sprite.modulate.a = 1.0
