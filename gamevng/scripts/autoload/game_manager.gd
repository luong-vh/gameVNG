extends Node

#target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}
var current_stage = ""
var player: Player = null
var stage_path
var _target_portal_name

signal stage_changed(new_stage_path)
signal earthquake_triggered(strength, duration)

func _ready() -> void:
	# Load checkpoint data when game starts
	load_checkpoint_data()
	SceneTransition.fade_to_black_finished.connect(teleport)
	SceneTransition.fade_from_black_finished.connect(able_to_control_player)

func able_to_control_player():
	player.set_physics_process(true)

func teleport() -> void:
	target_portal_name = _target_portal_name
	var scene_id = ResourceUID.text_to_id(stage_path)
		# 2. Lấy đường dẫn từ số ID đó
	var scene_path = ResourceUID.get_id_path(scene_id)
	
	if scene_path != current_stage.scene_file_path:
		get_tree().change_scene_to_file(stage_path)
		emit_signal("stage_changed", stage_path)
	else:
		respawn_at_portal()
	SceneTransition.fade_from_black()

#change stage by path and target portal name
func change_stage(_stage_path: String, __target_portal_name: String = "") -> void:
	SceneTransition.fade_to_black()
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
		GameManager.target_portal_name = ""
		true
	return false


# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state":player_state_dict,
		"stage_path": current_stage.scene_file_path,
		#"enemies":EnemyManager.get_enemies_state()
	}
	print("Checkpoint saved: ", checkpoint_id)


func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

#respawn at checkpoint
func respawn_at_checkpoint() -> void:
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

	if player != null:
		var player_state: Dictionary = checkpoint_info.get("player_state")
		if player_state == null:
			return
		player.load_state(player_state)
		print("Player respawned at checkpoint: ", current_checkpoint_id)
		return
	else:
		print("Player not found for respawn")
#check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded from save file")

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")

func reload_current_scene() -> void:
	current_stage.reload()

func collect_blade() -> void:
	player.collected_blade()
	Dialogic.VAR["PlayerHasBlade"] = true
