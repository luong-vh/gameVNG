extends Node

# Checkpoint system variables
var current_checkpoint_ids: Dictionary = {}
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}

var current_stage: Stage
var stage_path

var player: Player = null
var main_camera: Camera2D = null

var inventory_system: InventorySystem = null

#target portal name is the name of the portal to which the player will be teleported
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
	# Load checkpoint data when game starts
	load_checkpoint_data()
	GUIManager.fade_to_black_finished.connect(teleport)
	GUIManager.fade_from_black_finished.connect(able_to_control_player)

	# Initialize inventory system
	inventory_system = InventorySystem.new()
	add_child(inventory_system)
	
func set_player(_player: Player):
	player = _player
	player.healthChanged.connect(on_player_health_changed)
	GUIManager.update_heart_gui(player.health)

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
	var scene_id = ResourceUID.text_to_id(stage_path)
		# 2. Lấy đường dẫn từ số ID đó
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
		player.global_position = portal.global_position
		main_camera.global_position = portal.global_position
		GameManager.target_portal_name = ""
		true
	return false

# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = current_level_id + checkpoint_id
	current_checkpoint_ids[current_level_id] = current_checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	var objects_data = SaveSystem.collect_object_states()
	checkpoint_data[current_checkpoint_id] = {
		"player_state":player_state_dict,
		"stage_path": current_stage.scene_file_path,
		"objects": objects_data
		#"enemies":EnemyManager.get_enemies_state()
	}
	print("Checkpoint saved: ", current_checkpoint_id)

func get_current_checkpoint_id() -> String:
	var index = current_level_id.length()
	return current_checkpoint_id.substr(index)
	
# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_ids": current_checkpoint_ids,
		"checkpoint_data": checkpoint_data
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
		print("No checkpoint available")
		return

	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		print("Checkpoint data not found")
		return
	# Load the stage if different
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	if current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		return

	# Can change stage if different but not implemented yet to test
	#	change_stage(checkpoint_stage, "")
	#	# Wait for scene to load
	#	await get_tree().process_frame

	# Restore object states từ checkpoint
	if checkpoint_info.has("objects"):
		SaveSystem.restore_object_states(checkpoint_info.objects)
		print("✅ Restored %d objects from checkpoint" % checkpoint_info.objects.size())

	if player != null:
		var player_state: Dictionary = checkpoint_info.get("player_state")
		if player_state == null:
			return
		player.load_state(player_state)
		if main_camera !=null:
			main_camera.global_position = player.global_position
		print("Player respawned at checkpoint: ", current_checkpoint_id)
		return
	else:
		print("Player not found for respawn")

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
		current_checkpoint_ids = save_data.get("current_checkpoint_ids", "")
		
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded from save file")
	
	if save_data.has("objects"):
		SaveSystem.restore_object_states(save_data.objects)
		print("✅ Restored %d objects" % save_data.objects.size())
	print("Checkpoint data loaded from save file")

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")

func respawn_at_ground_checkpoint():
	if not _last_ground_checkpoint:
		player.global_position = Vector2(0,0)
		return
	
	if player.health <= 0 :
		return
	GUIManager.fade_from_black()
	player.lock_input(0.3)
	player.global_position = _last_ground_checkpoint.global_position
	main_camera.global_position = player.global_position
	
func set_current_stage(stage: Stage, level_id: String):
	current_stage = stage
	current_level_id = level_id

func stage_clear():
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
	var scene_path = "res://levels/level_%d/level_%d.tscn"%[level,level]
	print("Load scene: %s" %scene_path)
	get_tree().change_scene_to_file(scene_path)


func next_level():
	current_level += 1
	var scene_path = "res://levels/level_%d/level_%d.tscn"%[current_level,current_level]
	print("Load scene: %s" %scene_path)
	get_tree().change_scene_to_file(scene_path)
