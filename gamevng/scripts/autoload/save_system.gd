extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"
const LEVEL_FILE = "user://level_save.dat"

const MAX_LEVEL = 8
# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	
	if file == null:
		push_error("Can not open save file! Error: %s" % FileAccess.get_open_error())
		return

	file.store_var(data)
	file.close()

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	# 1. Kiểm tra xem file có tồn tại không
	if not FileAccess.file_exists(SAVE_FILE):
		print("[SaveSystem] No save file found")
		return {} # Trả về Dictionary rỗng nếu không có file

	# 2. Mở file để đọc
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	
	if file == null:
		push_error("Can not open save file! Error: %s" % FileAccess.get_open_error())
		return {}

	# 3. Dùng get_var để đọc và giải mã data
	var data = file.get_var()
	file.close()
	
	if data is Dictionary:
		return data
	else:
		push_error("Data in save file is invalid!")
		return {}
		
func save_level_data(data: Dictionary):
	var file = FileAccess.open(LEVEL_FILE, FileAccess.WRITE)
	
	if file == null:
		push_error("Can not open save file! Error: %s" % FileAccess.get_open_error())
		return

	file.store_var(data)
	file.close()

func load_level_data() -> Dictionary:
	# 1. Kiểm tra xem file có tồn tại không
	if not FileAccess.file_exists(LEVEL_FILE):
		var data = {
			"max_level":MAX_LEVEL,
			"unlocked_level":1
		}
		save_level_data(data)
		return data

	# 2. Mở file để đọc
	var file = FileAccess.open(LEVEL_FILE, FileAccess.READ)
	
	if file == null:
		push_error("Can not open save file! Error: %s" % FileAccess.get_open_error())
		return {}

	# 3. Dùng get_var để đọc và giải mã data
	var data = file.get_var()
	file.close()
	
	if data is Dictionary:
		return data
	else:
		push_error("Data in save file is invalid!")
		return {}
		
# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		
func delete_level_data():
	if FileAccess.file_exists(LEVEL_FILE):
		DirAccess.remove_absolute(LEVEL_FILE)
		
func reset_data():
	delete_level_data()
	delete_save_file()
	
func collect_object_states(root_node: Node = null) -> Dictionary:
	if root_node == null:
		root_node = get_tree().current_scene

	var states := {}
	_collect_recursive(root_node, states)
	return states

func _collect_recursive(node: Node, states: Dictionary) -> void:
	# Check for SaveableObject first
	if node is SaveableObject and node.save_enabled:
		var obj = node as SaveableObject
		states[obj.object_id] = obj.get_state()
	# Also check for BaseCollectible (Area2D with save methods)
	elif node is BaseCollectible and node.save_enabled:
		var obj = node as BaseCollectible
		states[obj.object_id] = obj.get_state()

	for child in node.get_children():
		_collect_recursive(child, states)


func restore_object_states(states: Dictionary, root_node: Node = null, confirm_after_restore: bool = false) -> void:
	if root_node == null:
		root_node = get_tree().current_scene

	await get_tree().process_frame
	await get_tree().process_frame

	_restore_recursive(root_node, states, confirm_after_restore)

func _restore_recursive(node: Node, states: Dictionary, confirm_after_restore: bool) -> void:
	# Check for SaveableObject first
	if node is SaveableObject and node.save_enabled:
		var obj = node as SaveableObject
		if states.has(obj.object_id):
			obj.set_state(states[obj.object_id])
			# Confirm state after restore to update initial_state
			if confirm_after_restore and obj.has_method("confirm_current_state"):
				obj.confirm_current_state()
		else:
			obj.reset_to_initial()
	# Also check for BaseCollectible (Area2D with save methods)
	elif node is BaseCollectible and node.save_enabled:
		var obj = node as BaseCollectible
		if states.has(obj.object_id):
			var state = states[obj.object_id]
			obj.set_state(state)
			# Confirm state after restore to update initial_state
			if confirm_after_restore:
				obj.confirm_current_state()
		else:
			# No saved state - reset to scene default (not checkpoint state)
			if obj.has_method("reset_to_scene_default"):
				obj.reset_to_scene_default()
			else:
				obj.reset_to_initial()

	for child in node.get_children():
		_restore_recursive(child, states, confirm_after_restore)
