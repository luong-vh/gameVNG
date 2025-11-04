extends Node
<<<<<<< HEAD

var enemies: Array = []
var enemy_scenes: Dictionary = {}
var active_stage: Node = null

func _ready() -> void:
	print("EnemyManger ready!")
	GameManager.connect("stage_changed" , Callable(self , "_on_stage_changed"))
	GameManager.connect("checkpoint_loaded", Callable(self, "_on_checkpoint_loaded"))
	GameManager.connect("player_died", Callable(self, "_on_player_died"))



func register_enemy(enemy : EnemyCharacter) -> void:
	if not enemies.has(enemy):
		enemies.append(enemy)


func unregister_enemy(enemy: EnemyCharacter) -> void:
	if enemies.has(enemy):
		enemies.erase(enemy)

func spawn_enemy(enemy_scene_name: String , position: Vector2) -> EnemyCharacter:
	if not enemy_scenes.has(enemy_scene_name):
		enemy_scenes[enemy_scene_name] = load("res://levels/Enemies/%s.tscn" % enemy_scene_name)
	var enemy_scene = enemy_scenes[enemy_scene_name]
	var enemy = enemy_scene.instantiate() as EnemyCharacter
	active_stage.add_child(enemy)
	enemy.global_position = position
	register_enemy(enemy)
	return enemy

func clear_enemies() -> void:
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()

func _on_stage_changed(new_stage: Node) -> void:
	active_stage = new_stage
	clear_enemies()

func _on_checkpoint_loaded(data: Dictionary) -> void:
	clear_enemies()
	if data.has("enemies"):
		for enemy_info in data["enemies"]:
			spawn_enemy(enemy_info["scene"], enemy_info["pos"])

func _on_player_died() -> void:
	for e in enemies:
		if is_instance_valid(e):
			e.set_physics_process(false)

func get_enemies_state() -> Array:
	var data: Array = []
	for e in enemies:
		if is_instance_valid(e):
			data.append({
				"scene": e.scene_file_path,
				"pos": e.global_position
			})
	return data
=======
var enemies_by_type: Dictionary = {}

func _ready() -> void:
	DayNightManager.state_changed.connect(_day_night_changed)

func add_enemy(enemy, type_name: String):
	if not enemies_by_type.has(type_name):
		enemies_by_type[type_name] = []
	enemies_by_type[type_name].append(enemy)

func remove_enemy(enemy, type_name: String):
	if enemies_by_type.has(type_name):
		enemies_by_type[type_name].erase(enemy)
		if enemies_by_type[type_name].is_empty():
			enemies_by_type.erase(type_name)

func get_all_by_type(type_name: String) -> Array:
	return enemies_by_type.get(type_name, [])

func get_all_enemies() -> Array:
	var all = []
	for type_name in enemies_by_type.keys():
		all += enemies_by_type[type_name]
	return all
	
func _day_night_changed(new_state):
	if new_state == DayNightManager.DayNightState.DAY:
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				enemy.change_to_day_behavior()
	else:
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				enemy.change_to_night_behavior()
>>>>>>> 9b76a46d7c3aa59720745ab6e4276c65ed77620c
