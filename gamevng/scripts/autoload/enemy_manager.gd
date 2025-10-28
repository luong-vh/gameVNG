extends Node

var enemies: Array = []

func _ready() -> void:
	GameManager.stage_changed.connect(_on_stage_changed)
	_init_enemy_list()
	pass

func on_enemy_died():
	pass

func _init_enemy_list():
	enemies = get_tree().get_nodes_in_group("Enemy")
	pass

func _on_stage_changed(new_stage_path: String):
	_init_enemy_list()

func _on_day_night_changed(new_stage: DayNightManager.DayNightState):
	pass
