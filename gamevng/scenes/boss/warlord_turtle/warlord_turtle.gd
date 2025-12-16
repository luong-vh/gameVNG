extends EnemyCharacter

@export var idle_time_day: float = 1.0
@export var idle_time_night: float = 0.5
@export var bullet_speed: float = 300

var current_idle_time: float = 4.0
@onready var cannon_scene = preload("res://scenes/boss/warlord_turtle/warlord_bullet/cannon.tscn")
@onready var rocket_scene = preload("res://scenes/boss/warlord_turtle/warlord_bullet/rocket.tscn")
@onready var bullet_spawn_point = $Direction/BulletFactory

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	type = "WARLORD_TURTLE"
	spawn_point = global_position
	current_idle_time = idle_time_day
	super._ready()

func _process(delta: float) -> void:
	detect_player()

func _add_into_enemy_manager():
	EnemyManager.add_enemy(self, type)

func _delete_from_enemy_manager():
	EnemyManager.remove_enemy(self, type)

func change_to_day_behavior():
	current_idle_time = idle_time_day
	print("[%s] → DAY: slower attacks" % name)

func change_to_night_behavior():
	current_idle_time = idle_time_night
	print("[%s] → NIGHT: faster attacks" % name)

func fire_cannon() -> void:
	var container = get_tree().current_scene.find_child("Bullets")
	if not container:
		return
	
	# Fire first cannon (slightly above)
	var cannon1 = cannon_scene.instantiate() as RigidBody2D
	cannon1.global_position = bullet_spawn_point.global_position + Vector2(0, -10)
	container.add_child(cannon1)
	var shooting_velocity := Vector2(bullet_speed * direction * 1.5, 0.0)
	cannon1.apply_impulse(shooting_velocity)
	
	# Fire second cannon (slightly below)
	var cannon2 = cannon_scene.instantiate() as RigidBody2D
	cannon2.global_position = bullet_spawn_point.global_position + Vector2(0, 10)
	container.add_child(cannon2)
	cannon2.apply_impulse(shooting_velocity)

func fire_rocket() -> void:
	var container = get_tree().current_scene.find_child("Bullets")
	if not container:
		return
	
	# Fire first rocket (center, high arc)
	var rocket1 = rocket_scene.instantiate() as RigidBody2D
	rocket1.global_position = bullet_spawn_point.global_position
	container.add_child(rocket1)
	var shooting_velocity1 := Vector2(bullet_speed * direction, -400.0)
	rocket1.apply_impulse(shooting_velocity1)
	
	# Fire second rocket (left/above, slightly different angle)
	var rocket2 = rocket_scene.instantiate() as RigidBody2D
	rocket2.global_position = bullet_spawn_point.global_position + Vector2(0, -15)
	container.add_child(rocket2)
	var shooting_velocity2 := Vector2(bullet_speed * direction * 0.9, -450.0)
	rocket2.apply_impulse(shooting_velocity2)
	
	# Fire third rocket (right/below, slightly different angle)
	var rocket3 = rocket_scene.instantiate() as RigidBody2D
	rocket3.global_position = bullet_spawn_point.global_position + Vector2(0, 15)
	container.add_child(rocket3)
	var shooting_velocity3 := Vector2(bullet_speed * direction * 1.1, -350.0)
	rocket3.apply_impulse(shooting_velocity3)

func _on_changed_direction() -> void:
	if direction == -1:
		$Direction.scale.x = -1
	elif direction == 1:
		$Direction.scale.x = 1
