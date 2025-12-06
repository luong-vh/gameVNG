extends Node

var enemies_by_type: Dictionary = {}
var night_spawn_points: Array = []

var enemy_scenes := {
	"": preload("res://scenes/enemies/crab/crab.tscn"),
	"BARREL": preload("res://scenes/enemies/barrel/barrel.tscn"),
	"STARFISH": preload("res://scenes/enemies/starfish/starfish.tscn"),
	"MUSHROOM": preload("res://scenes/enemies/mushroom/mushroom.tscn"),
	"TURTLE": preload("res://scenes/enemies/turtle/turtle.tscn"),
	"SPEAR": preload("res://scenes/enemies/shield_native/spear.tscn")
}

func _ready() -> void:
	DayNightManager.day_night_state_changed.connect(_day_night_changed)

func add_enemy(enemy, type_name: String):
	if not enemies_by_type.has(type_name):
		enemies_by_type[type_name] = []
	enemies_by_type[type_name].append(enemy)
	#print("[EnemyManager] ➕ Added enemy: %s (type: %s)" % [enemy.name, type_name])
	print_current_status()

func remove_enemy(enemy, type_name: String):
	if enemies_by_type.has(type_name):
		enemies_by_type[type_name].erase(enemy)
		if enemies_by_type[type_name].is_empty():
			enemies_by_type.erase(type_name)
	print_current_status()

func get_all_by_type(type_name: String) -> Array:
	# Clean up freed enemies before returning
	_clean_freed_enemies()
	return enemies_by_type.get(type_name, [])

func get_all_enemies() -> Array:
	# Clean up freed enemies before returning
	_clean_freed_enemies()
	var all = []
	for type_name in enemies_by_type.keys():
		all += enemies_by_type[type_name]
	return all

# New helper function to clean up freed enemies
func _clean_freed_enemies():
	for type_name in enemies_by_type.keys():
		var valid_enemies = []
		for enemy in enemies_by_type[type_name]:
			if is_instance_valid(enemy):
				valid_enemies.append(enemy)
		
		if valid_enemies.is_empty():
			enemies_by_type.erase(type_name)
		else:
			enemies_by_type[type_name] = valid_enemies

func _day_night_changed(new_state):
	#print("\n[EnemyManager] 🌗 Day/Night state changed to: %s" % str(new_state))
	
	if new_state == DayNightManager.DayNightState.DAY:
		var to_remove = []
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				# Check if enemy is still valid before accessing properties
				if not is_instance_valid(enemy):
					to_remove.append([enemy, type_name])
					continue
				
				if enemy.spawn_only_at_night:
					enemy.queue_free()
					to_remove.append([enemy, type_name])
				else:
					#print("   → Changing %s (%s) to DAY mode" % [enemy.name, type_name])
					enemy.change_to_day_behavior()
		
		for pair in to_remove:
			remove_enemy(pair[0], pair[1])
	else:
		# Spawn night enemies
		for sp in night_spawn_points:
			#print("[SpawnPoint] -> ", sp)
			var e = sp.spawn_enemy()
			if e and e.spawn_only_at_night:
				#add_enemy(e, e.type)
				pass
		
		# Change existing enemies to night mode
		for type_name in enemies_by_type.keys():
			for enemy in enemies_by_type[type_name]:
				if is_instance_valid(enemy):
					#print("   → Changing %s (%s) to NIGHT mode" % [enemy.name, type_name])
					enemy.change_to_night_behavior()
	
	print_current_status()

func print_current_status():
	#print("[EnemyManager] 🧩 Current enemies:")
	for type_name in enemies_by_type.keys():
		var names = []
		for e in enemies_by_type[type_name]:
			# Check if enemy is still valid before accessing name
			if is_instance_valid(e):
				names.append(e.name)
			else:
				names.append("[FREED]")
		#print("   • %s: %s" % [type_name, names])
	#print("---------------------------------------------")

func register_spawn_point(point: EnemySpawnPoint):
	night_spawn_points.append(point)

func save_all() -> Array:
	var result: Array = []
	for type_name in enemies_by_type.keys():
		for enemy in enemies_by_type[type_name]:
			if is_instance_valid(enemy):
				result.append(enemy.serialize())
	return result

func load_all(saved_enemies: Array) -> void:
	# Clear all current enemies
	for e in get_all_enemies():
		if is_instance_valid(e):
			e.queue_free()
	enemies_by_type.clear()
	
	# Load each enemy
	for e_data in saved_enemies:
		if e_data.spawn_only_at_night and DayNightManager.is_day():
			continue  # Skip if it's daytime
		
		var enemy = _spawn_enemy_from_type(e_data.type)
		if enemy:
			enemy.apply_serialized(e_data)
			add_enemy(enemy, e_data.type)

func _spawn_enemy_from_type(t: String):
	if not enemy_scenes.has(t):
		push_error("Enemy type not found: " + t)
		return null
	var inst = enemy_scenes[t].instantiate()
	get_tree().current_scene.add_child(inst)
	return inst
