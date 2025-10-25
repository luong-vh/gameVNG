extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	
	if file == null:
		push_error("Can not open save file! Error: %s" % FileAccess.get_open_error())
		return

	file.store_var(data)
	file.close()
	print("Saved data to file: ", SAVE_FILE)


# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	# 1. Kiểm tra xem file có tồn tại không
	if not FileAccess.file_exists(SAVE_FILE):
		print("Save file is not found.")
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

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")
