extends MarginContainer

@onready var popup_settings_scene = preload("res://scenes/gui/game_screen/settings_popup.tscn")

# Resource display
@onready var coin_icon: TextureRect = $HBoxContainer/ResourcesContainer/CoinContainer/CoinIcon
@onready var coin_label: Label = $HBoxContainer/ResourcesContainer/CoinContainer/CoinLabel
@onready var key_icon: TextureRect = $HBoxContainer/ResourcesContainer/KeyContainer/KeyIcon
@onready var key_label: Label = $HBoxContainer/ResourcesContainer/KeyContainer/KeyLabel

func _ready() -> void:
	update_coin_display(0)
	update_key_display(0)

func update_coin_display(amount: int) -> void:
	if coin_label:
		coin_label.text = str(amount)

func update_key_display(amount: int) -> void:
	if key_label:
		key_label.text = str(amount)

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = popup_settings_scene.instantiate()
	get_parent().add_child(popup_settings)
