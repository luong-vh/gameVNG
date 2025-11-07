extends Node
class_name SaveLoadEnemy

const SAVE_PATH := "user://enemy_save.json"

func save_enemies() -> void:
	var data := EnemyManager.save_all()
	var json_text := JSON.stringify(data)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_text)

	print("[SaveLoadEnemy] ✅ Enemy data saved.")

func load_enemies() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveLoadEnemy] ⚠ No save file found.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	var data: Variant = JSON.parse_string(json_text)


	if typeof(data) != TYPE_ARRAY:
		push_error("[SaveLoadEnemy] ❌ Save file corrupted!")
		return

	print("[SaveLoadEnemy] 🔄 Loading enemies...")
	EnemyManager.load_all(data)
	DayNightManager.resend_state()
	print("[SaveLoadEnemy] ✅ Enemy data loaded.")


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveLoadEnemy] 🗑 Save deleted.")

@export var auto_save_interval := 60.0  # giây
var _timer := 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= auto_save_interval:
		_timer = 0
		save_enemies()
