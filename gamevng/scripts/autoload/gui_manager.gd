extends CanvasLayer

# 1. Định nghĩa các tín hiệu
signal fade_to_black_finished
signal fade_from_black_finished
var setting_popup_scene

@onready var _fade_animation_player = $FadeController/AnimationPlayer
@onready var _heart_container = $CanvasLayer/HeartsContainer

func _ready():
	_fade_animation_player.animation_finished.connect(_on_animation_finished)

func fade_to_black():
	_fade_animation_player.play("fade_to_black")

func fade_from_black():
	_fade_animation_player.play("fade_from_black")

func on_level_selection_scene():
	_heart_container.visible = false
	setting_popup_scene = preload("res://scenes/gui/game_screen/settings_level_selection_popup.tscn")

func on_stage_scene():
	_heart_container.visible = true
	setting_popup_scene = preload("res://scenes/gui/game_screen/settings_popup.tscn")
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		emit_signal("fade_to_black_finished")
	elif anim_name == "fade_from_black":
		emit_signal("fade_from_black_finished")

func set_max_heart_gui(max :int):
	if max > 10:
		print("wtf max health = %d??" %max)
		_heart_container.set_max_heart(5)
		return
	_heart_container.set_max_heart(max)

func update_heart_gui(health: int):
	if (health <=0): return
	var hearts = _heart_container.get_children()
	if hearts.size() == 0: return
		
	for i in range(health):
		if i >= hearts.size(): return
		hearts[i].update(true)
		
	for i in range(health,hearts.size()):
		hearts[i].update(false)
		
func play_SFX(name: String):
	match name:
		"coin":
			$SFX/Coin.play()
		"jump":
			$SFX/Jump.play()
		_:
			return

func open_stage_clear_popup():
	var stage_clear_popup_preload = preload("res://scenes/gui/game_screen/finished_level_poppup.tscn")
	var popup = stage_clear_popup_preload.instantiate()
	$CanvasLayer.add_child(popup)


func _on_settings_texture_button_pressed() -> void:
	var popup_settings = setting_popup_scene.instantiate()
	$CanvasLayer.add_child(popup_settings)
