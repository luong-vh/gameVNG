extends Node

const DATA_VERSION = "1.2"

var current_checkpoint_ids: Dictionary = {}
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}

var current_stage: Stage
var stage_path

var player: Player = null
var main_camera: Camera2D = null

var inventory_system: InventorySystem = null
var item_manager: ItemManager = null

var target_portal_name: String = ""
var _target_portal_name
var _last_ground_checkpoint: GroundCheckPointArea = null

signal stage_changed(new_stage_path)
signal earthquake_triggered(strength, duration)

var current_level_id : String =""

var max_level : int = 0
var unlocked_level = 0
var current_level = 0

func _ready() -> void:
	load_checkpoint_data()
	GUIManager.fade_to_black_finished.connect(teleport)
	GUIManager.fade_from_black_finished.connect(able_to_control_player)

	inventory_system = InventorySystem.new()
	add_child(inventory_system)

	item_manager = ItemManager.new()
	add_child(item_manager)
	
func set_player(_player: Player):
	player = _player
	player.healthChanged.connect(on_player_health_changed)
	GUIManager.update_heart_gui(player.health)

func get_player() -> Player:
	return player

func _sync_collectibles_with_inventory() -> void:
	if not current_stage:
		return

	var has_keys = inventory_system and inventory_system.has_key()
	var collectibles = get_tree().get_nodes_in_group("collectibles")

	for collectible in collectibles:
		if collectible is BaseCollectible:
			if collectible.get("is_key_collectible"):
				if not has_keys and collectible.collected:
					collectible.reset_to_scene_default()
				elif has_keys and not collectible.collected:
					collectible.collected = true
					collectible.visible = false
					collectible.monitoring = false

func on_player_health_changed():
	GUIManager.update_heart_gui(player.health)

func collect_blade():
	player.collect_blade()

func able_to_control_player():
	player.set_physics_process(true)

func reset_level():
	var prefix: String = current_level_id
	var all_keys: Array = current_checkpoint_ids.keys()
	for key in all_keys:
		if key.begins_with(prefix):
			checkpoint_data.erase(current_checkpoint_ids[key])
			current_checkpoint_ids.erase(key)
	var save_data = {
		"current_checkpoint_ids": current_checkpoint_ids,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)
	get_tree().reload_current_scene()
	
func teleport() -> void:
	if _target_portal_name == null:
		return
	target_portal_name = _target_portal_name
	if stage_path!="":
		var scene_id = ResourceUID.text_to_id(stage_path)
		var scene_path = ResourceUID.get_id_path(scene_id)
		
		if scene_path != current_stage.scene_file_path:
			get_tree().change_scene_to_file(stage_path)
			emit_signal("stage_changed", stage_path)
	else:
		respawn_at_portal()
	GUIManager.fade_from_black()

#change stage by path and target portal name
func change_stage(_stage_path: String, __target_portal_name: String = "") -> void:
	GUIManager.fade_to_black()
	stage_path = _stage_path
	_target_portal_name = __target_portal_name
	player.set_physics_process(false)

#call from dialogic
func call_from_dialogic(msg:String = ""):
	#Dialogic.VAR["PlayerScore"] = 30
	print("Call from dialogic " + msg)

#respawn at portal or door
func respawn_at_portal() -> bool:
	if not target_portal_name.is_empty():
		var portal = current_stage.find_child(target_portal_name)
		player.global_position = portal.spawn_position
		main_camera.global_position = portal.spawn_position
		GameManager.target_portal_name = ""
		return true
	return false

# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = current_level_id + checkpoint_id
	current_checkpoint_ids[current_level_id] = current_checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	var objects_data = SaveSystem.collect_object_states()
	var inventory_state = inventory_system.save_state()
	checkpoint_data[current_checkpoint_id] = {
		"player_state":player_state_dict,
		"stage_path": current_stage.scene_file_path,
		"objects": objects_data,
		"inventory": inventory_state
		#"enemies":EnemyManager.get_enemies_state()
	}

# Lưu completion checkpoint - chỉ lưu coins và collectibles, không lưu player position và chest
func save_completion_checkpoint() -> void:
	var completion_checkpoint_id = current_level_id + "_completion"
	current_checkpoint_ids[current_level_id] = completion_checkpoint_id

	# Chỉ lấy collectibles (coins, keys, etc), filter ra chest, door, và objects lớn khác
	var all_objects = SaveSystem.collect_object_states()
	var collectibles_only = {}

	for object_id in all_objects.keys():
		# Filter: KHÔNG lưu chest, door, button, checkpoint, steering wheel, etc
		var id_lower = object_id.to_lower()
		if id_lower.contains("chest") or \
		   id_lower.contains("door") or \
		   id_lower.contains("button") or \
		   id_lower.contains("checkpoint") or \
		   id_lower.contains("wheel") or \
		   id_lower.contains("lever") or \
		   id_lower.contains("gate"):
			continue  # Bỏ qua object này

		# Giữ lại các collectibles nhỏ (coins, keys, potions, shield, etc)
		collectibles_only[object_id] = all_objects[object_id]

	var inventory_state = inventory_system.save_state()

	# Lưu một phần player state (chỉ has_blade, health) - KHÔNG lưu position
	var partial_player_state = {
		"has_blade": player.has_blade if player else false,
		"health": player.health if player else 3
	}

	checkpoint_data[completion_checkpoint_id] = {
		# KHÔNG lưu full player_state - player sẽ spawn ở vị trí ban đầu
		"stage_path": current_stage.scene_file_path,
		"objects": collectibles_only,  # Chỉ coins và collectibles
		"inventory": inventory_state,
		"partial_player_state": partial_player_state,  # Chỉ has_blade và health
		"is_completion": true  # Đánh dấu đây là completion checkpoint
	}

func get_current_checkpoint_id() -> String:
	var index = current_level_id.length()
	return current_checkpoint_id.substr(index)
	
# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_ids": current_checkpoint_ids,
		"checkpoint_data": checkpoint_data,
		"current_version": DATA_VERSION
	}
	SaveSystem.save_checkpoint_data(save_data)

func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

#respawn at checkpoint
func respawn_at_checkpoint() -> void:
	current_checkpoint_id = current_checkpoint_ids.get(current_level_id,"")

	if current_checkpoint_id.is_empty():
		print("[GameManager] No checkpoint for level %s" % current_level_id)
		# No checkpoint exists for this level
		# Reset collectibles/objects to initial state
		SaveSystem.restore_object_states({})  # Empty dict = all objects reset to initial
		# Reset keys to 0 (each level has its own key), but keep coins
		if inventory_system:
			inventory_system.keys = 0
		# Sync collectibles with inventory
		call_deferred("_sync_collectibles_with_inventory")
		return

	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		# Sync player blade state in case of missing checkpoint
		call_deferred("_sync_player_blade")
		call_deferred("_sync_collectibles_with_inventory")
		return

	# Kiểm tra xem đây có phải completion checkpoint không
	var is_completion = checkpoint_info.get("is_completion", false)

	# Load the stage if different
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	if current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		# Different stage - sync player blade state
		call_deferred("_sync_collectibles_with_inventory")
		return

	# Restore object states từ checkpoint
	if checkpoint_info.has("objects"):
		# Pass true to confirm_after_restore to update initial_state of restored objects
		SaveSystem.restore_object_states(checkpoint_info.objects, null, true)

	# Restore inventory state từ checkpoint
	if checkpoint_info.has("inventory"):
		inventory_system.load_state(checkpoint_info.inventory)

	# Sync collectibles with inventory after restore
	call_deferred("_sync_collectibles_with_inventory")

	# Chỉ load player state nếu KHÔNG phải completion checkpoint
	if not is_completion:
		if player != null:
			var player_state: Dictionary = checkpoint_info.get("player_state")
			if player_state != null:
				player.load_state(player_state)
				if main_camera != null:
					main_camera.global_position = player.global_position
	else:
		# Completion checkpoint: restore chỉ has_blade và health, KHÔNG restore position
		if player != null and checkpoint_info.has("partial_player_state"):
			var partial_state = checkpoint_info.partial_player_state

			if partial_state.has("has_blade"):
				if partial_state.has_blade:
					player.collect_blade()
				else:
					player.drop_blade()

			if partial_state.has("health"):
				player.health = partial_state.health

#check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

func activate_checkpoint():
	#player.health = player.max_health
	pass

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		if save_data.has("current_version"):
			var current_version = save_data.get("current_version")
			if current_version != DATA_VERSION:
				print("Checkpoint data is old version! Reseted data.")
				SaveSystem.reset_data()
				return
		else:
			print("Checkpoint data is old version! Reseted data.")
			SaveSystem.reset_data()
			return
		current_checkpoint_ids = save_data.get("current_checkpoint_ids", {})
		
		checkpoint_data = save_data.get("checkpoint_data", {})

	if save_data.has("objects"):
		SaveSystem.restore_object_states(save_data.objects)

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()

func respawn_at_ground_checkpoint():
	GUIManager.fade_from_black()
	if not _last_ground_checkpoint:
		get_tree().reload_current_scene()
		return
	
	if player.health <= 0 :
		return
	
	player.lock_input(0.3)
	player.global_position = _last_ground_checkpoint.global_position
	main_camera.global_position = player.global_position
	
func set_current_stage(stage: Stage, level_id: String):
	current_stage = stage
	current_level_id = level_id

func stage_clear():
	# Lưu completion checkpoint (chỉ coins, không lưu player position và chest)
	save_completion_checkpoint()
	save_checkpoint_data()

	if unlocked_level == current_level:
		unlocked_level += 1
		save_level_data()
	GUIManager.open_stage_clear_popup()
	
func load_level_data():
	var data = SaveSystem.load_level_data()
	max_level = data["max_level"]
	unlocked_level = data["unlocked_level"]

func save_level_data():
	var data = {
		"max_level":max_level,
		"unlocked_level":unlocked_level
	}
	SaveSystem.save_level_data(data)

func level_selected(level: int):
	current_level = level
	var scene_path = "res://levels/level_%d.tscn"%level
	get_tree().change_scene_to_file(scene_path)


func next_level():
	current_level += 1
	var scene_path = "res://levels/level_%d.tscn"%current_level
	get_tree().change_scene_to_file(scene_path)
