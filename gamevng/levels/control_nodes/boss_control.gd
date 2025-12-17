extends SaveableObject

@export var enemy_data: Array[EnemySpawnData] = []
@export var completed: bool = false
@onready var enemies_node = $EnemiesMarker
@onready var doors_node = $Doors
@onready var torches_node = $Torches
@onready var activation_area = $ActivationArea2D

var all_enemies_dead: bool = false
var activated: bool = false

func _ready() -> void:
	super._ready()
	activation_area.interaction_available.connect(_on_player_enter)
	
	# Initial setup - doors open by default
	open_doors()
	if completed:
		all_enemies_dead = true
		clear_enemies()
		_release_torches()

func _on_player_enter() -> void:
	if activated or completed:
		return
	
	activated = true
	close_doors()
	_force_torches_on()
	spawn_enemies()

func clear_enemies() -> void:
	for child in enemies_node.get_children():
		if child.has_signal("died") or child.get("health") != null:
			child.queue_free()

func spawn_enemies() -> void:
	if enemy_data.is_empty():
		push_error("No enemy data assigned!")
		return
	
	var spawn_markers = enemies_node.get_children()
	if spawn_markers.is_empty():
		push_error("No spawn markers found!")
		return
	
	var marker_index := 0
	for data in enemy_data:
		if data == null or data.scene == null:
			continue
		
		for i in range(data.count):
			if marker_index >= spawn_markers.size():
				push_warning("Not enough spawn markers!")
				return
			
			var marker = spawn_markers[marker_index]
			spawn_enemy(data.scene, marker.global_position)
			marker.queue_free()
			marker_index += 1

func spawn_enemy(enemy_scene: PackedScene, pos: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	enemies_node.add_child(enemy)
	
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	check_all_enemies_dead()

func check_all_enemies_dead() -> void:
	if all_enemies_dead:
		return
	
	for enemy in enemies_node.get_children():
		if enemy.get("health") != null and enemy.health > 0:
			return
	
	all_enemies_dead = true
	completed = true
	open_doors()
	_release_torches()

func open_doors() -> void:
	for door in doors_node.get_children():
		if door.has_method("open"):
			door.open()

func close_doors() -> void:
	for door in doors_node.get_children():
		if door.has_method("close"):
			door.close()

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
