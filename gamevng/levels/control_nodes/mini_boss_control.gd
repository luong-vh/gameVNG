extends Node2D

@export var enemy_data: Array[EnemySpawnData] = []
@export var completed: bool = false

@onready var enemies_node = $Enemies
@onready var doors_node = $Doors
@onready var interactive_area = $InteractiveArea2D
var all_enemies_dead: bool = false

func _ready():
	interactive_area.interaction_available.connect(_on_interactive)
	if completed:
		# If already completed, open doors immediately
		open_doors()

func _on_interactive():
	# Trigger enemy spawn from external event
	spawn_enemies()

func spawn_enemies():
	# Don't spawn if already completed
	if completed:
		print("Room already completed, skipping enemy spawn")
		return
	
	# Don't spawn if enemies already spawned
	if enemies_node.get_child_count() > 0:
		# Check if any are actual enemies (not just markers)
		for child in enemies_node.get_children():
			if child.has_signal("died"):
				print("Enemies already spawned")
				return
	
	var spawn_markers = enemies_node.get_children()
	
	if spawn_markers.is_empty():
		push_error("No spawn markers found in Enemies node!")
		return
	
	if enemy_data.is_empty():
		push_error("No enemy data assigned!")
		return
	
	var marker_index = 0
	
	# Spawn each enemy type with its specified count
	for data in enemy_data:
		if data == null or data.scene == null:
			push_warning("Invalid enemy data entry!")
			continue
		
		# Spawn 'count' number of this enemy type
		for i in range(data.count):
			if marker_index >= spawn_markers.size():
				push_warning("Not enough spawn markers for all enemies!")
				return
			
			var marker = spawn_markers[marker_index]
			var spawn_pos = marker.global_position
			
			# Spawn enemy and remove marker
			spawn_enemy(data.scene, spawn_pos)
			marker.queue_free()
			
			marker_index += 1

func spawn_enemy(enemy_scene: PackedScene, pos: Vector2):
	if enemy_scene == null:
		push_error("Enemy scene is null!")
		return
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	enemies_node.add_child(enemy)
	
	# Connect to enemy's death signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	# Check if all enemies are dead
	check_all_enemies_dead()

func check_all_enemies_dead():
	if all_enemies_dead:
		return  # Already processed
	
	var all_dead = true
	for enemy in enemies_node.get_children():
		if enemy.has_method("get") and enemy.health > 0:
			all_dead = false
			break
	
	if all_dead:
		all_enemies_dead = true
		completed = true
		open_doors()

func open_doors():
	# Open all doors in the doors_node
	for door in doors_node.get_children():
		if door.has_method("open"):
			door.open()
	print("All enemies defeated! Opening doors...")
