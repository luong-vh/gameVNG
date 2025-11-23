extends Node2D
class_name EnemySpawnPoint

@export var enemy_scene: PackedScene

func _enter_tree() -> void:
	var t = enemy_scene.instantiate()
	t.global_position = global_position
	#get_tree().current_scene.add_child(t)
	get_tree().current_scene.call_deferred("add_child", t)

func spawn_enemy():
	if enemy_scene == null:
		push_error("[EnemySpawnPoint] enemy_scene is not assigned!")
		return null

	var e = enemy_scene.instantiate()
	e.global_position = global_position
	get_tree().current_scene.add_child(e)
	return e
