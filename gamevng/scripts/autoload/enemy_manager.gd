extends Node
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
