extends EnemyCharacter


@export var attack_cooldown: float = 0.5
@export var speed = 100 
@export var bullet_speed: float = 300

# Fire skill properties
@export var napalm_speed: float = 250.0
@export var fireball_velocity: Vector2 = Vector2(300, -500)

# Meteor skill properties
@export var meteor_count: int = 8
@export var meteor_spawn_height: float = -300.0
@export var meteor_spread_range: float = 500.0
@export var meteor_delay_between: float = 0.3

@onready var bullet_factory = $Direction/BulletFactory
@onready var fire_spawn_point: Marker2D = null
@onready var fireball_scene = preload("res://scenes/boss/king_crab/fire_moveset/fireballs.tscn")
@onready var meteor_scene = preload("res://scenes/boss/king_crab/fire_moveset/meteor.tscn")

var original_speed: float
var original_player_raycast_length: float 
var is_phase_2: bool = false

func _ready() -> void:
	super._ready()
	type = "KINGCRAB"
	fsm = FSM.new(self, $States, $States/Idle)
	
	#store default speed
	original_speed = speed
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		original_player_raycast_length = shape.shape.size.x

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _process(delta: float) -> void:
	detect_player()

func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		# Override direction moving - inverted for visual purposes
		if direction == -1:
			$Direction.scale.x = 1
		elif direction == 1:
			$Direction.scale.x = -1
		
		# Counter-flip raycasts so they always point in correct direction
		if front_ray_cast:
			front_ray_cast.scale.x = -$Direction.scale.x
		if down_ray_cast:
			down_ray_cast.scale.x = -$Direction.scale.x
	
func _add_into_enemy_manager():
	EnemyManager.add_enemy(self,type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self,type)

func change_to_day_behavior():
	# Restore original speed and detection range
	speed = original_speed
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		shape.shape.size.x = original_player_raycast_length

func change_to_night_behavior():
	# Decrease speed and detection range for night
	speed = original_speed * 0.6 # Reduce speed by 40%
	var shape = $PlayerRayCast2D.get_child(0) as CollisionShape2D
	if shape and shape.shape:
		shape.shape.size.x = original_player_raycast_length * 0.5 # Reduce detection range by 50%

func fire() -> void:
	var bullet := bullet_factory.create() as RigidBody2D
	var shooting_velocity := Vector2(bullet_speed * direction, 0.0)
	bullet.apply_impulse(shooting_velocity)

func fire_fireball() -> void:
	var fireball = fireball_scene.instantiate()
	
	var spawn_pos = global_position
	if fire_spawn_point:
		spawn_pos = fire_spawn_point.global_position
	else:
		spawn_pos += Vector2(direction * 50, -50)
	
	fireball.position = spawn_pos
	
	get_parent().add_child(fireball)
	
	if fireball.has_method("set_velocity"):
		fireball.set_velocity(Vector2(fireball_velocity.x * direction, fireball_velocity.y))
	elif "initial_velocity" in fireball:
		fireball.initial_velocity = Vector2(fireball_velocity.x * direction, fireball_velocity.y)

func cast_meteors() -> void:
	var target_pos = global_position
	if player:
		target_pos = player.global_position
	
	# Use a consistent ground level for all meteors
	var ground_level = target_pos.y
	
	for i in meteor_count:
		var offset_x = randf_range(-meteor_spread_range, meteor_spread_range)
		var meteor_x = target_pos.x + offset_x
		
		var meteor = meteor_scene.instantiate()
		meteor.position = Vector2(meteor_x, ground_level + meteor_spawn_height)
		meteor.ground_y = ground_level
		
		get_parent().add_child(meteor)
		
		if i < meteor_count - 1:
			await get_tree().create_timer(meteor_delay_between).timeout
