class_name Player
extends BaseCharacter
## Player character class that handles movement, combat, and state management

var lock_input_timer: Timer
var light_source: Light2D
var decorator_manager: DecoratorManager = null

# --- INVULNERABILITY ---
@export_category("Invulnerability")
var is_invulnerable: bool = false
@onready var invulnerable_timer: Timer = $InvulnerableTimer
@export var blink_speed: int = 3

# --- ATTACK ---
@export_category("Attack")
enum AttackDir { FORWARD, UP, DOWN }
var attack_direction: AttackDir = AttackDir.FORWARD
@export var has_blade: bool = false
@export var attack_cd_sec: float = 0.3
@onready var attack_timer := $AttackCoolDownTimer
@export var throwing_speed: float = 300
@onready var blade_factory = $Direction/BladeFactory
var hit_area_collision
var pogo_hit_area_collision
@export var attack_knockback_force: float = 100
@export var pogo_bounce_force: float = 200.0

# --- WALL JUMP & CLING ---
@export_category("Wall Jump & Cling")
@export var can_wall_cling: bool = false
@export var wall_friction: float = 300.0
@export var wall_jump_force: float = 120.0
@export var wall_slide_speed: float = 200.0
var wall_checker: RayCast2D

# --- DOUBLE JUMP ---
@export_category("Double Jump")
@export var can_double_jump: bool = false
@export var max_jump_amount: int = 1
var jump_count = 1
@onready var jump_particle = $Direction/Particles/JumpParticle
@export var normal_jump_cost: float = 1
@export var double_jump_cost: float = 2

# --- DASH ---
@export_category("Dash")
@export var can_dash: bool = false
@export var dash_length: float = 0.2
@export var dash_speed: float = 600.0
@export var dash_amount: int = 1
@export var between_dash_cd: float = 0.1
@export var dash_cd: float = 0.4
var dash_count: int = 0
@onready var dash_particle: GPUParticles2D = $Direction/Particles/DashParticle
@onready var dash_timer: Timer = $DashCoolDownTimer

# --- RAYCASTS ---
@export_category("Raycasts")
var raycast_pushable: RayCast2D

func _ready() -> void:
	super._ready()
	set_animated_sprite($Direction/AnimatedSprite2D)
	fsm = FSM.new(self, $States, $States/Idle)
	_init_hit_hurt_area()
	_init_wall_cling()

	# Initialize decorator manager for powerups
	decorator_manager = DecoratorManager.new()
	decorator_manager.initialize(self)
	add_child(decorator_manager)

	if has_blade:
		# Player spawns with blade pre-equipped
		collect_blade()  # Add to hotbar
		equip_blade()    # Auto-equip at spawn
		print("[Player] Spawned with blade equipped")
	
	if has_node("LockInputTimer"):
		lock_input_timer = get_node("LockInputTimer")
	
	if has_node("Light2D"):
		light_source = get_node("Light2D")
	
	if has_node("Direction/CheckPushable"):
		raycast_pushable = $Direction/CheckPushable
	
	GameManager.set_player(self)
	GUIManager.set_max_heart_gui(max_health)
	Dialogic.VAR["PlayerHasBlade"] = has_blade
	DayNightManager.day_night_state_changed.connect(_day_night_changed)
	DayNightManager.shader_stage_changed.connect(_shader_changed)

func _init_wall_cling():
	## Setup wall cling
	if has_node("Direction/WallChecker"):
		wall_checker = get_node("Direction/WallChecker")
	else:
		print("Has no wall checker")

func _init_hit_hurt_area():
	if has_node("Direction/HitArea2D") and has_node("Direction/HitArea2D/CollisionShape2D"):
		var hit_area = $Direction/HitArea2D
		hit_area.hitted.connect(_on_area_hitted)
		hit_area_collision = $Direction/HitArea2D/CollisionShape2D
		hit_area_collision.disabled = true
	else:
		print("Fail to init hit area")
	
	if has_node("Direction/PogoHitArea2D") and has_node("Direction/PogoHitArea2D/CollisionPolygon2D"):
		var hit_area = $Direction/PogoHitArea2D
		hit_area.hitted.connect(_on_area_hitted)
		pogo_hit_area_collision = $Direction/PogoHitArea2D/CollisionPolygon2D
		pogo_hit_area_collision.disabled = true
	else:
		print("Fail to init pogo hit area")
	
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

func start_attack_cd() -> bool:
	if attack_timer:
		attack_timer.start(attack_cd_sec)
		return true
	return false

func can_attack() -> bool:
	return has_blade and attack_timer.time_left <= 0

func change_attack_direction(dir: AttackDir):
	if attack_direction != dir:
		attack_direction = dir

func collect_blade() -> void:
	print("[Player] Collecting blade (adding to hotbar)...")

	# Add blade icon to hotbar slot 0 - NOT equipped yet
	if GameManager.inventory_system:
		var blade_texture = load("res://assets/items/blade.png")
		if blade_texture:
			GameManager.inventory_system.set_hotbar_slot(0, "blade", blade_texture, 1)
			print("[Player] ✅ Blade added to hotbar slot 0 (press 1 to equip)")
		else:
			print("[Player] ❌ Failed to load blade texture")

	# DON'T auto-equip - player must press 1 to equip
	# has_blade stays false until player presses 1

func equip_blade() -> void:
	"""Equip blade when player uses it from hotbar (press 1)"""
	print("[Player] Equipping blade...")
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = true
	print("[Player] ✅ Blade equipped! (can now throw with attack button)")

func drop_blade():
	print("[Player] Dropping blade...")
	has_blade = false
	set_animated_sprite($Direction/AnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = false

	# Remove blade from hotbar slot 0
	if GameManager.inventory_system:
		GameManager.inventory_system.clear_hotbar_slot(0)
	print("[Player] Blade dropped and removed from hotbar")

func unequip_blade():
	"""Unequip blade but keep in hotbar"""
	print("[Player] Unequipping blade...")
	has_blade = false
	set_animated_sprite($Direction/AnimatedSprite2D)
	Dialogic.VAR["PlayerHasBlade"] = false
	print("[Player] Blade unequipped (still in hotbar)")

func throw_blade():
	print("[Player] Throwing blade...")
	var blade := blade_factory.create() as RigidBody2D
	var throwing_velocity := Vector2(throwing_speed * direction, 0.0)
	blade.apply_impulse(throwing_velocity)

	# Unequip and remove from inventory
	has_blade = false
	Dialogic.VAR["PlayerHasBlade"] = false
	set_animated_sprite($Direction/AnimatedSprite2D)
	change_animation("idle")

	# Remove blade from hotbar when thrown
	if GameManager.inventory_system:
		GameManager.inventory_system.clear_hotbar_slot(0)
	print("[Player] Blade thrown and lost from inventory")

func _has_blade_in_hotbar() -> bool:
	"""Check if blade exists in hotbar slot 0"""
	if not GameManager.inventory_system:
		return false
	var item = GameManager.inventory_system.get_hotbar_item(0)
	return item != null and item.item_name == "blade"

func is_near_wall() -> bool:
	if wall_checker:
		return wall_checker.is_colliding()
	else:
		return false

func reset_jump_count():
	jump_count = 0

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
		if dash_count < dash_amount:
			dash_timer.start(between_dash_cd)
		else:
			dash_timer.start(dash_cd)
		return true
	return false

func is_dash_on_cd() -> bool:
	return dash_timer.time_left > 0

func set_invulnerable()->void:
	is_invulnerable = true
	invulnerable_timer.start()

func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y],
		"has_blade": [has_blade],
		"health": [max_health]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	#print(data)
	if data.has("position"):
		print("loaded position")
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
	
	if data.has("has_blade"):
		print("loaded has_blade")
		var saved_has_blade = data["has_blade"][0]
		if saved_has_blade:
			# Player had blade equipped when saved
			collect_blade()  # Add to hotbar first
			equip_blade()    # Then equip it
			print("Blade restored to hotbar and equipped")
		else:
			# Player didn't have blade
			drop_blade()
	
	if data.has("health"):
		health = data["health"][0]
		print("loaded health %d" %health)
	fsm.change_state(fsm.states.idle)

func _on_take_damge(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)

func _on_area_hitted(area: Area2D) -> void:
	if area == null:
		return
	
	var knockback_vector: Vector2 = Vector2.ZERO
	if area is HurtArea2D and area.have_knockback:
		match attack_direction:
			AttackDir.FORWARD:
				# Push away from enemy
				knockback_vector = Vector2(-direction * attack_knockback_force, 0)
			AttackDir.UP:
				# Smaller downward recoil
				knockback_vector = Vector2(0, attack_knockback_force * 0.5)
			AttackDir.DOWN:
				knockback_vector = Vector2(0, -pogo_bounce_force)
	elif area is PogoArea2D and area.have_knockback:
		knockback_vector = Vector2(0, -pogo_bounce_force)
	
	if knockback_vector != Vector2.ZERO:
		apply_knockback(knockback_vector, knockback_vector.length())

func apply_knockback(direction: Vector2, force_amount: float) -> void:
	if direction == Vector2.ZERO:
		return
	var knockback = direction.normalized() * force_amount
	velocity = knockback

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if Input.is_action_just_pressed("switch_day_night"):
		DayNightManager.switch_day_night_state()
	
	handle_invulnerable()

func handle_invulnerable():
	if invulnerable_timer.time_left > 0:
		var alpha := 0.5 + 0.5 * sin(invulnerable_timer.time_left * TAU * blink_speed)
		animated_sprite.modulate.a = alpha
	else:
		animated_sprite.modulate.a = 1.0

	if invulnerable_timer.is_stopped():
		is_invulnerable = false

# --- POWERUP SYSTEM ---
func get_movement_speed() -> float:
	if decorator_manager != null:
		return decorator_manager.get_effective_movement_speed()
	return movement_speed

func get_jump_speed() -> float:
	if decorator_manager != null:
		return decorator_manager.get_effective_jump_speed()
	return jump_speed

func get_max_jumps() -> int:
	if decorator_manager != null:
		return decorator_manager.get_effective_max_jumps()
	return max_jump_amount

func collect_powerup(powerup_id: String) -> void:
	if decorator_manager != null:
		decorator_manager.apply_powerup(powerup_id)
		print("Applied powerup: ", powerup_id)
	else:
		print("ERROR: DecoratorManager not initialized!")

func speed_up(multiplier: float, duration: float) -> void:
	movement_speed = movement_speed * multiplier
	await get_tree().create_timer(duration).timeout
	movement_speed = movement_speed / multiplier
