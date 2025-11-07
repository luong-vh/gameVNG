extends Node2D

@onready var dialog_box = $DialogBox

func _ready() -> void:
	if dialog_box != null:
		dialog_box.visible = false
func _on_interactive_area_2d_interacted() -> void:
	Dialogic.start("collect_blade")
	pass # Replace with function body.

func _open_dialog():
	if dialog_box !=null:
		dialog_box.visible = true

func _close_dialog():
	if dialog_box !=null:
		dialog_box.visible = false

func _on_interactive_area_2d_interaction_available() -> void:
	_open_dialog()


func _on_interactive_area_2d_interaction_unavailable() -> void:
	_close_dialog()
