extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var player = $Player

var dialog_finished = false
var animation_started = false

func _ready() -> void:
	if player:
		var sprite = player.get_node("Direction/AnimatedSprite2D")
		if player.has_blade:
			sprite = player.get_node("Direction/BladeAnimatedSprite2D")
		
		if sprite:
			sprite.visible = true
			sprite.play("idle")  # Start with idle, animation will control movement
	
	# Connect to the fade finished signal
	GUIManager.fade_to_black_finished.connect(_on_fade_finished)
	
	# Check if Dialogic is available
	if Dialogic:
		# Connect to Dialogic timeline finished signal
		Dialogic.timeline_ended.connect(_on_dialog_finished)
		
		# Start the dialog first
		print("[Opening] Starting dialog: opening_cutscene")
		Dialogic.start("opening_cutscene")
		
		# Auto-progress dialog after a delay
		_auto_advance_dialog()
		
		# Fallback: start animation after 10 seconds if dialog doesn't finish
		await get_tree().create_timer(10.0).timeout
		if not animation_started:
			print("[Opening] Fallback: Dialog took too long, starting animation anyway")
			_start_animation()
	else:
		print("[Opening] Dialogic not found, starting animation immediately")
		_start_animation()


func _auto_advance_dialog() -> void:
	# Auto-advance through dialog every 2 seconds by simulating input
	for i in range(5):  # Max 5 advances
		await get_tree().create_timer(2.0).timeout
		if not dialog_finished and Dialogic.current_timeline != null:
			print("[Opening] Auto-advancing dialog...")
			# Simulate the dialogic_default_action input
			var event = InputEventAction.new()
			event.action = "dialogic_default_action"
			event.pressed = true
			Input.parse_input_event(event)


func _on_dialog_finished() -> void:
	print("[Opening] Dialog finished!")
	dialog_finished = true
	_start_animation()


func _start_animation() -> void:
	if animation_started:
		return  # Already started
	
	animation_started = true
	print("[Opening] Starting animation: new_animation")
	
	# After dialog finishes, start the cutscene animation
	if animation_player:
		animation_player.play("new_animation")
		print("[Opening] Animation playing: new_animation")
	else:
		print("[Opening] ERROR: AnimationPlayer not found!")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("[Opening] Animation finished: ", anim_name)
	# When animation finishes, start fade to black
	GUIManager.fade_to_black()


func _on_fade_finished() -> void:
	print("[Opening] Fade finished, changing scene to level 1")
	# Mark intro cutscene as played
	GameManager.intro_cutscene_played = true
	# Save the flag so it persists
	GameManager.save_level_data()
	# After fade completes, change to level 1
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
