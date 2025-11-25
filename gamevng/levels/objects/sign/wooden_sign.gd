extends Node2D

@onready var dialog = $DialogBox
@onready var message_label: Label = $DialogBox/PanelContainer/MarginContainer/Label

@export_multiline var message: String = "Edit message text!"

@export var fade_duration: float = 0.3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.visible = false
	dialog.modulate.a = 0.0
	
	message_label.text = message


func show_dialog():
	dialog.visible = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(dialog, "modulate:a", 1.0, fade_duration)
	tween.parallel().tween_property(dialog, "scale", Vector2.ONE, fade_duration).from(Vector2(0.8, 0.8))

func hide_dialog():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(dialog, "modulate:a", 0.0, fade_duration)
	tween.parallel().tween_property(dialog, "scale", Vector2(0.8, 0.8), fade_duration)
	
	await tween.finished
	dialog.visible = false

# Change message dễ dàng
func set_message(new_message: String):
	message = new_message
	message_label.text = new_message


func _on_interactive_area_2d_interacted() -> void:
	pass # Replace with function body.
