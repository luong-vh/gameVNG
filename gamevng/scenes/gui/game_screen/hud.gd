extends MarginContainer

@onready var popup_settings_scene = preload("res://scenes/gui/game_screen/settings_popup.tscn")

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = popup_settings_scene.instantiate()
	get_parent().add_child(popup_settings)
