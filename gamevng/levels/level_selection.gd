extends CanvasLayer

var buttons: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_buttons()
	GUIManager.on_level_selection_scene()
	
func set_up_buttons():
	buttons = $Setting/LevelButtons.get_children()
	GameManager.load_level_data()
	var max_level = GameManager.max_level
	var unlocked_level = GameManager.unlocked_level
	
	for i in range(unlocked_level):
		buttons[i].is_locked = false
		buttons[i].level_num = i + 1
		
	for i in range(unlocked_level,max_level):
		buttons[i].is_locked = true
		buttons[i].level_num = i + 1
