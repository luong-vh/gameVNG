class_name Player
extends BaseCharacter

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
var throwing_speed:float = 300
@export var has_blade: bool = false
@onready var invulnerable_timer = $InvulnerableTimer
@onready var hit_area_collision = $Direction/HitArea2D/CollisionShape2D
@onready var blade_factory = $Direction/BladeFactory
func _ready() -> void:
	hit_area_collision.disabled = true
	super._ready()
	if has_node("Direction/HurtArea2D"):
		$Direction/HurtArea2D.hurt.connect(_on_hurt_area_2d_hurt)
	set_animated_sprite($Direction/AnimatedSprite2D)
	fsm = FSM.new(self, $States, $States/Idle)
	if has_blade:
		collected_blade()
	GameManager.player = self
	Dialogic.VAR["PlayerHasBlade"] = has_blade
func can_attack() -> bool:
	return has_blade

func collected_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = true
func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y],
		"has_blade": [has_blade],
		"health": [health]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	print(data)
	if data.has("position"):
		print("loaded position")
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
	if data.has("has_blade"):
		print("loaded has_blade")
		has_blade = data["has_blade"][0]
		if has_blade:
			collected_blade()
	if data.has("health"):
		print("loaded health")
		health = data["health"][0]
	fsm.change_state(fsm.states.idle)
			
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)
func invulnerable()->void:
	is_invulnerable = true
	invulnerable_timer.start()
	
func _physics_process(delta: float) -> void:
	if invulnerable_timer.is_stopped():
		is_invulnerable = false
	if Input.is_action_just_pressed("attack"):
		if can_attack(): fsm.change_state(fsm.states.attack)
	if Input.is_action_just_pressed("throw"):
		if can_attack():
			has_blade = false
			Dialogic.VAR["PlayerHasBlade"] = false
			set_animated_sprite($Direction/AnimatedSprite2D)
			change_animation("idle")
			var blade :=blade_factory.create() as RigidBody2D
			var throwing_velocity := Vector2(throwing_speed * direction, 0.0)
			blade.apply_impulse(throwing_velocity)
			
	super._physics_process(delta)
