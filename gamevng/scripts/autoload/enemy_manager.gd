extends Node

var enemies_by_type: Dictionary = {}
var night_spawn_points: Array = []


func _ready() -> void:
	DayNightManager.state_changed.connect(_day_night_changed)

func add_enemy(enemy, type_name: String):
	if not enemies_by_type.has(type_name):
		enemies_by_type[type_name] = []
	enemies_by_type[type_name].append(enemy)
	print("[EnemyManager] ➕ Added enemy: %s (type: %s)" % [enemy.name, type_name])
	print_current_status()
func remove_enemy(enemy, type_name: String):
	if enemies_by_type.has(type_name):
		enemies_by_type[type_name].erase(enemy)
		if enemies_by_type[type_name].is_empty():
			enemies_by_type.erase(type_name)
	print_current_status()
func get_all_by_type(type_name: String) -> Array:
	return enemies_by_type.get(type_name, [])

func get_all_enemies() -> Array:
	var all = []
	for type_name in enemies_by_type.keys():
		all += enemies_by_type[type_name]
	return all
	
func _day_night_changed(new_state):
	print("\n[EnemyManager] 🌗 Day/Night state changed to: %s" % str(new_state))
	if new_state == DayNightManager.DayNightState.DAY:
		var to_remove = []
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				if enemy.spawn_only_at_night:
					enemy.queue_free()
					to_remove.append([enemy, type_name])
				else :
					print("   → Changing %s (%s) to DAY mode" % [enemy.name, type_name])
					enemy.change_to_day_behavior()
		for pair in to_remove:
			remove_enemy(pair[0], pair[1])
	else:
		for sp in night_spawn_points:
			print("[SpawnPoint] -> ", sp)
			var e = sp.spawn_enemy()
			if e.spawn_only_at_night:
				add_enemy(e, e.type)
			else:
				pass
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				print("   → Changing %s (%s) to NIGHT mode" % [enemy.name, type_name])
				enemy.change_to_night_behavior()
	print_current_status()
func print_current_status():
	print("[EnemyManager] 🧩 Current enemies:")
	for type_name in enemies_by_type.keys():
		var names = []
		for e in enemies_by_type[type_name]:
			names.append(e.name)
		print("   • %s: %s" % [type_name, names])
	print("---------------------------------------------")

func register_spawn_point(point: EnemySpawnPoint):
	night_spawn_points.append(point)
