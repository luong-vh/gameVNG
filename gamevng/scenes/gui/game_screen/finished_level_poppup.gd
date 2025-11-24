extends MarginContainer

func hide_popup():
	queue_free()
	
func _on_restart_button_pressed() -> void:
	GameManager.reset_level()
	hide_popup()


func _on_level_selection_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_selection.tscn")
	hide_popup()


func _on_next_level_button_pressed() -> void:
	print("next level")
	GameManager.next_level()
	hide_popup()
