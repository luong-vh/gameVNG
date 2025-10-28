extends Node

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
