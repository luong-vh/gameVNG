extends Control

func _input(event):
	if event.is_action_pressed("save_game"):
		print("✅ SAVE KEY PRESSED")
		SaveSystemEnemy.save_enemies()

	if event.is_action_pressed("load_game"):
		print("✅ LOAD KEY PRESSED")
		SaveSystemEnemy.load_enemies()
