extends SaveableObject

@export var enemy_data: Array[EnemySpawnData] = []
@export var completed: bool = false
@export var enemy_container_path: NodePath = ^"../../Enemies"  # Path to the Enemies node in the level
@onready var enemies_marker_node = $EnemiesMarker
@onready var doors_node = $Doors
@onready var torches_node = $Torches
@onready var activation_area = $ActivationArea2D

var enemy_container: Node = null
var all_enemies_dead: bool = false
var activated: bool = false
var debug_frame_count: int = 0

func _ready() -> void:
	super._ready()
	
	# Debug activation area setup
	print("=== BossControl _ready ===")
	print("BossControl position: ", global_position)
	print("ActivationArea2D exists: ", activation_area != null)
	if activation_area:
		print("ActivationArea2D monitoring: ", activation_area.monitoring)
		print("ActivationArea2D collision_mask: ", activation_area.collision_mask)
		print("ActivationArea2D position: ", activation_area.position)
		print("ActivationArea2D global_position: ", activation_area.global_position)
		var shapes = activation_area.get_children()
		print("ActivationArea2D has ", shapes.size(), " collision shapes")
		for shape in shapes:
			if shape is CollisionShape2D:
				print("  - CollisionShape2D disabled: ", shape.disabled)
				print("  - CollisionShape2D position: ", shape.position)
				if shape.shape:
					print("  - Shape type: ", shape.shape.get_class())
					if shape.shape is RectangleShape2D:
						print("  - Shape size: ", shape.shape.size)
	
	activation_area.body_entered.connect(_on_body_entered)
	print("BossControl ready, activation area connected")
	
	# Get the enemy container from the level
	if enemy_container_path:
		enemy_container = get_node_or_null(enemy_container_path)
		if enemy_container:
			print("Enemy container found: ", enemy_container.get_path())
		else:
			push_error("Enemy container not found at path: ", enemy_container_path)
	
	# Initial setup - doors open by default
	open_doors()
	if completed:
		all_enemies_dead = true
		clear_enemies()
		_release_torches()

func _physics_process(_delta: float) -> void:
	# Debug: Check if player is nearby every 60 frames
	debug_frame_count += 1
	if debug_frame_count >= 60:
		debug_frame_count = 0
		var player = get_tree().get_first_node_in_group("player")
		if player and activation_area:
			var distance = global_position.distance_to(player.global_position)
			if distance < 600:  # Only print if player is somewhat close
				print("Player distance from BossControl: ", distance)
				print("Player position: ", player.global_position)
				print("Activated: ", activated, ", Completed: ", completed)

func _on_body_entered(body: Node2D) -> void:
	print("Body entered boss area: ", body.name)
	# Check if it's the player
	if body.is_in_group("player"):
		print("Player detected! Triggering boss fight")
		_on_player_enter()

func _on_player_enter() -> void:
	print("_on_player_enter called, activated=", activated, ", completed=", completed)
	if activated:
		print("ERROR: Boss fight already activated! Ignoring.")
		return
	if completed:
		print("ERROR: Boss fight already completed! Ignoring.")
		return
	
	print("Starting boss fight!")
	activated = true
	close_doors()
	_force_torches_on()
	spawn_enemies()

func clear_enemies() -> void:
	if not enemy_container:
		return
	for child in enemy_container.get_children():
		if child.has_signal("died") or child.get("health") != null:
			child.queue_free()

func spawn_enemies() -> void:
	print("=== spawn_enemies called ===")
	print("enemy_data count: ", enemy_data.size())
	
	if enemy_data.is_empty():
		push_error("No enemy data assigned!")
		return
	
	if not enemy_container:
		push_error("No enemy container available!")
		return
	
	var spawn_markers = enemies_marker_node.get_children()
	print("spawn_markers count: ", spawn_markers.size())
	print("enemies_marker_node path: ", enemies_marker_node.get_path())
	
	if spawn_markers.is_empty():
		push_error("No spawn markers found!")
		return
	
	var marker_index := 0
	for data in enemy_data:
		if data == null or data.scene == null:
			print("Skipping null enemy data")
			continue
		
		print("Processing enemy data, scene: ", data.scene, ", count: ", data.count)
		
		for i in range(data.count):
			if marker_index >= spawn_markers.size():
				push_warning("Not enough spawn markers!")
				return
			
			var marker = spawn_markers[marker_index]
			print("Spawning enemy at marker position: ", marker.global_position)
			spawn_enemy(data.scene, marker.global_position)
			marker.queue_free()
			marker_index += 1

func spawn_enemy(enemy_scene: PackedScene, pos: Vector2) -> void:
	print("spawn_enemy called with scene: ", enemy_scene, " at position: ", pos)
	var enemy = enemy_scene.instantiate()
	
	# Add to tree FIRST before setting position
	enemy_container.add_child(enemy)
	
	# NOW set the global position after it's in the tree
	enemy.global_position = pos
	
	print("Enemy spawned: ", enemy.name, " at ", enemy.global_position, " in container: ", enemy_container.get_path())
	print("Enemy visible: ", enemy.visible)
	print("Enemy z_index: ", enemy.z_index if "z_index" in enemy else "N/A")
	print("Enemy is_inside_tree: ", enemy.is_inside_tree())
	
	# Make sure it's visible
	enemy.show()
	
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
		print("Connected died signal for: ", enemy.name)

func _on_enemy_died() -> void:
	check_all_enemies_dead()

func check_all_enemies_dead() -> void:
	if all_enemies_dead or not enemy_container:
		return
	
	for enemy in enemy_container.get_children():
		if enemy.get("health") != null and enemy.health > 0:
			return
	
	all_enemies_dead = true
	completed = true
	open_doors()
	_release_torches()

func open_doors() -> void:
	print("Opening doors, count: ", doors_node.get_child_count())
	for door in doors_node.get_children():
		if door.has_method("open"):
			door.open()
			print("Opened door: ", door.name)

func close_doors() -> void:
	print("Closing doors, count: ", doors_node.get_child_count())
	for door in doors_node.get_children():
		if door.has_method("close"):
			door.close()
			print("Closed door: ", door.name)

func _force_torches_on() -> void:
	for torch in torches_node.get_children():
		if torch.has_method("turn_on"):
			torch.turn_on()

func _release_torches() -> void:
	for torch in torches_node.get_children():
		if torch.has_method("clear_manual_override"):
			torch.clear_manual_override()

func get_state() -> Dictionary:
	return {
		"completed": completed,
	}

func set_state(state: Dictionary) -> void:
	# This gets called every time player respawns
	if state.has("completed"):
		completed = state.completed
	
	# CRITICAL: Reset room state on every load/respawn
	if completed:
		# Room was completed - keep it completed
		all_enemies_dead = true
		activated = true  # Prevent re-activation
		clear_enemies()
		open_doors()
		_release_torches()
	else:
		# Room not completed - reset everything
		all_enemies_dead = false
		activated = false  # Allow re-activation
		clear_enemies()
		open_doors()
		_release_torches()
