extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var player = $Player
@onready var end_game_label = $CanvasLayer/EndGameLabel

var dialog_finished = false
var animation_started = false

func _ready() -> void:
	if player:
		var sprite = player.get_node("Direction/AnimatedSprite2D")
		if player.has_blade:
			sprite = player.get_node("Direction/BladeAnimatedSprite2D")
		
		if sprite:
			sprite.visible = true
			sprite.play("idle")
	
	# Start with the label invisible
	if end_game_label:
		end_game_label.modulate.a = 0.0
	
	# Connect signals
	GUIManager.fade_to_black_finished.connect(_on_fade_finished)
	
	# Check if Dialogic is available
	if Dialogic:
		# Connect to Dialogic timeline finished signal
		Dialogic.timeline_ended.connect(_on_dialog_finished)
		
		# Start the dialog first
		print("[Ending] Starting dialog: ending_cutscene")
		Dialogic.start("ending_cutscene")
		
		# Auto-progress dialog after a delay
		_auto_advance_dialog()
	else:
		print("[Ending] Dialogic not found, starting animation immediately")
		_start_animation()


func _auto_advance_dialog() -> void:
	# Auto-advance through dialog every 2 seconds by simulating input
	for i in range(3):  # Max 3 advances
		await get_tree().create_timer(2.0).timeout
		if not dialog_finished and Dialogic.current_timeline != null:
			print("[Ending] Auto-advancing dialog...")
			# Simulate the dialogic_default_action input
			var event = InputEventAction.new()
			event.action = "dialogic_default_action"
			event.pressed = true
			Input.parse_input_event(event)


func _on_dialog_finished() -> void:
	print("[Ending] Dialog finished!")
	dialog_finished = true
	_start_animation()


func _start_animation() -> void:
	if animation_started:
		return
	
	animation_started = true
	print("[Ending] Starting animation: new_animation")
	
	if animation_player:
		animation_player.play("new_animation")
		print("[Ending] Animation playing: new_animation")
	else:
		print("[Ending] ERROR: AnimationPlayer not found!")
	
	# Fade in the "END GAME" text after 2 seconds
	await get_tree().create_timer(2.0).timeout
	_fade_in_end_game_text()


func _fade_in_end_game_text() -> void:
	if not end_game_label:
		return
	
	print("[Ending] Fading in END GAME text")
	var tween = create_tween()
	tween.tween_property(end_game_label, "modulate:a", 1.0, 2.0)
	
	# Wait 3 seconds then fade to black
	await tween.finished
	await get_tree().create_timer(3.0).timeout
	GUIManager.fade_to_black()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("[Ending] Animation finished: ", anim_name)


func _on_fade_finished() -> void:
	print("[Ending] Fade finished, returning to main menu or level selection")
	# You can change this to go to main menu or credits
	get_tree().change_scene_to_file("res://scenes/gui/game_screen/level_selection.tscn")
